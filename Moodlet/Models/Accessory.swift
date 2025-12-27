//
//  Accessory.swift
//  Moodlet
//

import Foundation
import SwiftData

@Model
final class Accessory {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageName: String
    var category: AccessoryCategory
    var price: Int
    var isPremiumOnly: Bool
    var requiredStreakMilestone: Int?

    init(
        name: String,
        imageName: String,
        category: AccessoryCategory,
        price: Int,
        isPremiumOnly: Bool = false,
        requiredStreakMilestone: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.category = category
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = requiredStreakMilestone
    }
}

enum AccessoryCategory: String, Codable, CaseIterable, Identifiable {
    case eyes
    case glasses
    case hat
    case top
    case heldItem = "held_item"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .eyes: return "Eyes"
        case .glasses: return "Glasses"
        case .hat: return "Hats"
        case .top: return "Tops"
        case .heldItem: return "Held Items"
        }
    }

    var icon: String {
        switch self {
        case .eyes: return "eye.fill"
        case .glasses: return "eyeglasses"
        case .hat: return "crown.fill"
        case .top: return "tshirt.fill"
        case .heldItem: return "hand.raised.fill"
        }
    }

    /// Layer order for rendering (lower = rendered first/behind)
    var layerOrder: Int {
        switch self {
        case .eyes: return 1
        case .top: return 2
        case .glasses: return 3
        case .hat: return 4
        case .heldItem: return 5
        }
    }
}
