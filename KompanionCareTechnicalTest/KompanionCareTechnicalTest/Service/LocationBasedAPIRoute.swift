//
//  LocationBasedAPIRoute.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation

protocol LocationBasedAPIRoute {
    var latitude: CLLocationDegrees { get }
    var longitude: CLLocationDegrees { get }
    
    var path: String { get }
    
    func queryItems() -> [URLQueryItem]
}

extension LocationBasedAPIRoute {
    func defaultQueryItems() -> [URLQueryItem] {
        [
            .init(name: "lat", value: String(format: "%.2f", latitude)),
            .init(name: "lon", value: String(format: "%.2f", longitude))
        ]
    }
}

struct GetTemperatureAPIRoute: LocationBasedAPIRoute {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    
    var path: String = "/data/2.5/weather"
    
    func queryItems() -> [URLQueryItem] {
        var queryItems = defaultQueryItems()
        queryItems.append(.init(name: "units", value: "metric"))
        return queryItems
    }
}

struct GetCityNameAPIRoute: LocationBasedAPIRoute {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    
    var path: String = "/geo/1.0/reverse"
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func queryItems() -> [URLQueryItem] {
        defaultQueryItems()
    }
}
