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
    case hat
    case glasses
    case scarf
    case heldItem = "held_item"
    case outfit

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hat: return "Hats"
        case .glasses: return "Glasses"
        case .scarf: return "Scarves"
        case .heldItem: return "Held Items"
        case .outfit: return "Outfits"
        }
    }

    var icon: String {
        switch self {
        case .hat: return "crown.fill"
        case .glasses: return "eyeglasses"
        case .scarf: return "wind"
        case .heldItem: return "hand.raised.fill"
        case .outfit: return "tshirt.fill"
        }
    }
}
