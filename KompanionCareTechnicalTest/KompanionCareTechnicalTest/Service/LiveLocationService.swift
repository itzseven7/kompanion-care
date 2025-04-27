//
//  LiveLocationService.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import Foundation
import CoreLocation

final class LiveLocationService: NSObject, LocationService {
    private let locationManager: LocationManager
    
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var serviceEnabledContinuation: CheckedContinuation<Bool, Never>?
    private var locationRequestContinuation: CheckedContinuation<CLLocation, Error>?
    
    init(locationManager: LocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }
    
    func isLocationAuthorized() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    @discardableResult
    private func locationManagerServicesIsEnabled() -> Bool {
        type(of: locationManager).locationServicesEnabled()
    }
    
    @discardableResult
    func requestLocationAuthorization() async -> CLAuthorizationStatus {
        return await withCheckedContinuation { [weak self] continuation in
            self?.authorizationContinuation = continuation
            self?.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @discardableResult
    func locationServicesEnabled() async -> Bool {
        return await withCheckedContinuation { [weak self] continuation in
            let isEnabled = self?.locationManagerServicesIsEnabled() ?? false
            
            if isEnabled {
                continuation.resume(returning: isEnabled)
            } else {
                self?.serviceEnabledContinuation = continuation
            }
        }
    }
    
    func fetchLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.locationRequestContinuation = continuation
            self?.locationManager.requestLocation()
        }
    }
    
    private func sendLocation(_ location: CLLocation) {
        locationRequestContinuation?.resume(returning: location)
        locationRequestContinuation = nil
    }
    
    private func sendManagerError(_ error: Error) {
        locationRequestContinuation?.resume(throwing: error)
        locationRequestContinuation = nil
    }
    
    private func sendAuthorizationStatus() {
        guard let authorizationContinuation else { return }
        authorizationContinuation.resume(returning: locationManager.authorizationStatus)
        self.authorizationContinuation = nil
    }
    
    private func sendIsEnabledStatus() {
        guard let serviceEnabledContinuation else { return }
        let isEnabled = type(of: self.locationManager).locationServicesEnabled()
        
        serviceEnabledContinuation.resume(returning: isEnabled)
        self.serviceEnabledContinuation = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension LiveLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        sendLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        sendManagerError(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        sendAuthorizationStatus()
        sendIsEnabledStatus()
    }
}
