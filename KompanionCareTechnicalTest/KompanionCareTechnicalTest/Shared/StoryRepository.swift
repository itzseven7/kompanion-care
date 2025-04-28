//
//  StoryRepository.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation

protocol StoryRepository {
    func stories() async -> [Story]
}
