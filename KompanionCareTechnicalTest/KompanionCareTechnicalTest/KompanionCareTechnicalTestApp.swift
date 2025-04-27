//
//  KompanionCareTechnicalTestApp.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 27/04/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct KompanionCareTechnicalTestApp: App {
    let locationService = LiveLocationService()
    let weatherRepository = LiveWeatherRepository()
    
    var body: some Scene {
        WindowGroup {
            WeatherView(
                store: .init(initialState: .init()) {
                    Weather(
                        locationService: locationService,
                        weatherRepository: weatherRepository
                    )
                }
            )
        }
    }
}
