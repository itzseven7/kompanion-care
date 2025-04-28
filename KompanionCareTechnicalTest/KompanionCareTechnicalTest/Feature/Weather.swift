//
//  Weather.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation
import ComposableArchitecture

@Reducer
struct Weather {
    let locationService: LocationService
    let weatherRepository: WeatherRepository
    
    @ObservableState
    struct State {
        var loading: Bool = false
        var locationServiceIsEnabled: Bool = false
        var locationServiceIsAuthorized: Bool = false
        var cityName: String?
        var temperature: String?
        var errorMessage: String?
    }
    
    indirect enum Action {
        case checkLocationServiceIsEnabled
        case locationServiceIsEnabled(Bool)
        case checkLocationPermission
        case askLocationPermission
        case fetchLocation
        case fetchTemperature(CLLocation)
        case setTemperatureAndCityName(Measurement<UnitTemperature>, String)
        case loading
        case stopLoading(Action)
        case setErrorMessage(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .checkLocationServiceIsEnabled:
                return .run { send in
                    await send(.loading)
                    let isEnabled = await locationService.locationServicesEnabled()
                    await send(
                        .stopLoading(
                            .locationServiceIsEnabled(isEnabled)
                        )
                    )
                }
            case .locationServiceIsEnabled(let enabled):
                state.locationServiceIsEnabled = enabled
                return .none
            case .checkLocationPermission:
                state.locationServiceIsAuthorized = locationService.isLocationAuthorized()
                return .send(.checkLocationServiceIsEnabled)
            case .askLocationPermission:
                return .run { send in
                    await locationService.requestLocationAuthorization()
                    await send(.checkLocationPermission)
                }
            case .fetchLocation:
                return .run { send in
                    await send(.loading)
                    
                    do {
                        let location = try await locationService.fetchLocation()
                        await send(.fetchTemperature(location))
                    } catch {
                        await send(
                            .stopLoading(
                                .setErrorMessage("Failed to fetch location")
                            )
                        )
                    }
                }
            case .fetchTemperature(let location):
                return .run { send in
                    let nextAction: Action
                    
                    do {
                        let temperature = try await weatherRepository.fetchTemperature(for: location)
                        let cityName = try await weatherRepository.fetchCityName(for: location)
                        nextAction = .setTemperatureAndCityName(temperature, cityName)
                    } catch LiveWeatherRepository.Error.failedToFetchTemperature {
                        // we can get the underlying error here if we need more details
                        nextAction = .setErrorMessage("Failed to fetch temperature")
                    } catch LiveWeatherRepository.Error.failedToFetchCityName {
                        nextAction = .setErrorMessage("Failed to fetch city name")
                    } catch {
                        nextAction = .setErrorMessage("Unexpected error occured")
                    }
                    
                    await send(
                        .stopLoading(
                            nextAction
                        )
                    )
                }
            case .setTemperatureAndCityName(let temperature, let cityName):
                state.temperature = MeasurementFormatter().string(from: temperature)
                state.cityName = cityName
                return .none
            case .loading:
                state.errorMessage = nil
                state.loading = true
                return .none
            case .stopLoading(let nextAction):
                state.errorMessage = nil
                state.loading = false
                return .send(nextAction)
            case .setErrorMessage(let message):
                state.errorMessage = message
                return .none
            }
        }
    }
}
