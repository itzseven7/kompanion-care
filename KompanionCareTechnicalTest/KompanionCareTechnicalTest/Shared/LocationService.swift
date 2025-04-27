//
//  LocationService.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation
import CoreLocation

protocol LocationService {
    func isLocationAuthorized() -> Bool
    @discardableResult
    func requestLocationAuthorization() async -> CLAuthorizationStatus
    
    @discardableResult
    func locationServicesEnabled() async -> Bool
    func fetchLocation() async throws -> CLLocation
}
