//
//  WeatherView.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import SwiftUI
import CoreLocation
import ComposableArchitecture

struct WeatherView: View {
    let store: StoreOf<Weather>
    
    var body: some View {
        Group {
            if store.loading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if store.errorMessage != nil {
                errorView
            } else if store.locationServiceIsAuthorized == false {
                locationAutorizationView
            } else if store.locationServiceIsEnabled == false {
                locationEnabledView
            } else if store.temperature != nil {
                weatherView
            } else {
                weatherRequestView
            }
        }
        .onAppear {
            store.send(.checkLocationPermission)
        }
    }
    
    private var locationAutorizationView: some View {
        VStack {
            Image(systemName: "location.slash")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text("Location service is not authorized, please give us authorization")
            Button {
                store.send(.askLocationPermission)
            } label: {
                Text("Give authorization")
            }
        }
        .padding()
    }
    
    private var locationEnabledView: some View {
        VStack {
            Image(systemName: "location.slash.fill")
                .imageScale(.large)
                .foregroundStyle(.gray)
            Text("Location service is not enabled")
        }
        .padding()
    }
    
    private var weatherRequestView: some View {
        VStack {
            Image(systemName: "sun.min.fill")
                .imageScale(.large)
                .foregroundStyle(.yellow)
            Text("You can now request your weather")
            Button {
                store.send(.fetchLocation)
            } label: {
                Text("Check weather!")
            }
        }
        .padding()
    }
    
    private var weatherView: some View {
        VStack {
            Image(systemName: "sun.min.fill")
                .imageScale(.large)
                .foregroundStyle(.yellow)
            Text("City: \(store.cityName ?? "")")
            Text("Temperature: \(store.temperature ?? "")")
        }
        .padding()
    }
    
    private var errorView: some View {
        VStack {
            Image(systemName: "xmark")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text("Error: \(store.errorMessage ?? "")")
        }
        .padding()
    }
}

#if DEBUG

class PreviewLocationService: LocationService {
    private var authorized = false
    
    func isLocationAuthorized() -> Bool {
        return authorized
    }
    
    func requestLocationAuthorization() async -> CLAuthorizationStatus {
        authorized = true
        return .authorizedWhenInUse
    }
    
    func locationServicesEnabled() -> Bool {
        return true
    }
    
    func fetchLocation() async throws -> CLLocation {
        throw Self.Error.failedToFetchLocation
        return .init(latitude: 0, longitude: 0)
    }
    
    enum Error: Swift.Error {
        case failedToFetchLocation
    }
}

struct PreviewWeatherRepository: WeatherRepository {
    func fetchTemperature(for location: CLLocation) async throws -> Measurement<UnitTemperature> {
        return .init(value: 28, unit: .celsius)
    }
    
    func fetchCityName(for location: CLLocation) async throws -> String {
        return "Paris"
    }
}

#endif

#Preview {
    WeatherView(store: .init(initialState: Weather.State(), reducer: {
        Weather(
            locationService: PreviewLocationService(),
            weatherRepository: PreviewWeatherRepository()
        )
    }))
}
