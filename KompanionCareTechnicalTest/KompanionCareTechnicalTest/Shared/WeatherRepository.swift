//
//  WeatherRepository.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation

protocol WeatherRepository {
    func fetchTemperature(for location: CLLocation) async throws -> Measurement<UnitTemperature>
    func fetchCityName(for location: CLLocation) async throws -> String
}


