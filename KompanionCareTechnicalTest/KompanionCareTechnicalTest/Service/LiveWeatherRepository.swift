//
//  LiveWeatherRepository.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation

struct TemperatureResponse: Decodable {
    let current: Current
    
    struct Current: Decodable {
        let temperature: Double
        
        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case current = "main"
    }
}

struct CityNameResponse: Decodable {
    let name: String
}

struct LiveWeatherRepository: WeatherRepository {
    
    let session: URLSessionProtocol = URLSession.shared
    let decoder = JSONDecoder()
    
    private func getContent<T: Decodable>(from route: LocationBasedAPIRoute) async throws -> T {
        let builder = URLBuilder(
            route: route
        )
        
        let url = try builder.build()
        
        let (data, _) = try await session.data(from: url, delegate: nil)
        
        return try decoder.decode(T.self, from: data)
    }
    
    func fetchTemperature(for location: CLLocation) async throws -> Measurement<UnitTemperature> {
        let temperature: TemperatureResponse = try await getContent(
            from: GetTemperatureAPIRoute(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )
        
        return .init(value: temperature.current.temperature, unit: .celsius)
    }
    
    func fetchCityName(for location: CLLocation) async throws -> String {
        let cities: [CityNameResponse] = try await getContent(
            from: GetCityNameAPIRoute(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )
        
        guard let firstCityName = cities.first?.name else {
            throw Self.Error.noCity
        }
        
        return firstCityName
    }
    
    enum Error: Swift.Error {
        case noCity
    }
}

private struct URLBuilder {
    private let route: LocationBasedAPIRoute
    
    init(route: LocationBasedAPIRoute) {
        self.route = route
    }
    
    func build() throws -> URL {
        guard let apiKey = APIConstants.weatherAPIKey else {
            throw Self.Error.noApiKey
        }
        
        let baseURLString = APIConstants.weatherAPIBaseURL
        
        guard let baseURL = URL(string: "\(baseURLString ?? "")"), var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw Self.Error.invalidBaseURL
        }
        
        var queryItems = route.queryItems()
        queryItems.append(.init(name: "appid", value: apiKey))
        
        components.queryItems = queryItems
        components.path = route.path
        
        guard let url = components.url else {
            throw Self.Error.invalidURL
        }
        
        print("")
        
        return url
    }
    
    enum Error: Swift.Error {
        case noApiKey
        case invalidBaseURL
        case invalidURL
    }
}
