//
//  LiveStoryRepository.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation
import SwiftUI

struct LiveStoryRepository: StoryRepository {
    func stories() async -> [Story] {
        [
            .init(id: 1, image: Image(systemName: "sun.max.fill"), isSeen: false, color: .orange),
            .init(id: 2, image: Image(systemName: "moon.fill"), isSeen: false, color: .yellow),
            .init(id: 3, image: Image(systemName: "cloud.fill"), isSeen: false, color: .black),
            .init(id: 4, image: Image(systemName: "cloud.bolt.fill"), isSeen: false, color: .gray),
            .init(id: 5, image: Image(systemName: "cloud.moon.fill"), isSeen: false, color: .blue),
        ]
    }
}
