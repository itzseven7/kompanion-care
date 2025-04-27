//
//  LocationManager.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation

/// A protocol to abstract CLLocationManager for testing purpose
protocol LocationManager: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    
    var authorizationStatus: CLAuthorizationStatus { get }
    var desiredAccuracy: CLLocationAccuracy { get set }
    
    func requestWhenInUseAuthorization()
    func requestLocation()
    static func locationServicesEnabled() -> Bool
}

extension CLLocationManager: LocationManager {}
