//
//  Story.swift
//  KompanionCareTechnicalTest
//
//  Created by Romain Dubreucq on 28/04/2025.
//

import Foundation
import SwiftUI

struct Story: Hashable, Identifiable {
    let id: Int
    var image: Image
    let color: Color
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
