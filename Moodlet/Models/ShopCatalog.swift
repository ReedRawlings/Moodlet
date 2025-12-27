//
//  ShopCatalog.swift
//  Moodlet
//
//  Central catalog of all shop items. Add new items here and they'll
//  automatically appear for all users on next app launch.
//

import Foundation

/// Defines an accessory available in the shop
struct AccessoryDefinition {
    let imageName: String  // Stable identifier - must be unique
    let name: String
    let category: AccessoryCategory
    let price: Int
    let isPremiumOnly: Bool
    let requiredStreakMilestone: Int?

    init(
        _ imageName: String,
        name: String,
        category: AccessoryCategory,
        price: Int,
        isPremiumOnly: Bool = false,
        streakMilestone: Int? = nil
    ) {
        self.imageName = imageName
        self.name = name
        self.category = category
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = streakMilestone
    }
}

/// Defines a background available in the shop
struct BackgroundDefinition {
    let imageName: String  // Stable identifier - must be unique
    let name: String
    let price: Int
    let isPremiumOnly: Bool
    let requiredStreakMilestone: Int?

    init(
        _ imageName: String,
        name: String,
        price: Int,
        isPremiumOnly: Bool = false,
        streakMilestone: Int? = nil
    ) {
        self.imageName = imageName
        self.name = name
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = streakMilestone
    }
}

// MARK: - Shop Catalog

/// Central catalog of all shop items
/// Add new items here and they'll automatically sync to all users
enum ShopCatalog {

    // MARK: - Accessories

    static let accessories: [AccessoryDefinition] = [
        // ═══════════════════════════════════════════════════════════════
        // GLASSES
        // ═══════════════════════════════════════════════════════════════
        AccessoryDefinition("cool_glasses", name: "Cool Glasses", category: .glasses, price: 8),
        AccessoryDefinition("orange_glasses", name: "Orange Glasses", category: .glasses, price: 10),
        AccessoryDefinition("reading_glasses", name: "Reading Glasses", category: .glasses, price: 12),
        AccessoryDefinition("star_glasses", name: "Star Glasses", category: .glasses, price: 15),

        // ═══════════════════════════════════════════════════════════════
        // HATS
        // ═══════════════════════════════════════════════════════════════
        AccessoryDefinition("party_hat", name: "Party Hat", category: .hat, price: 10),
        AccessoryDefinition("nurse", name: "Nurse Hat", category: .hat, price: 15),
        AccessoryDefinition("pizza", name: "Pizza Hat", category: .hat, price: 20),

        // ═══════════════════════════════════════════════════════════════
        // TOPS
        // ═══════════════════════════════════════════════════════════════
        AccessoryDefinition("bluejacket", name: "Blue Jacket", category: .top, price: 15),
        AccessoryDefinition("skullshirt", name: "Skull Shirt", category: .top, price: 12),
        AccessoryDefinition("varsitypng", name: "Varsity Jacket", category: .top, price: 18),

        // ═══════════════════════════════════════════════════════════════
        // EYES
        // ═══════════════════════════════════════════════════════════════
        // (Add eye accessories here when you have images)

        // ═══════════════════════════════════════════════════════════════
        // HELD ITEMS
        // ═══════════════════════════════════════════════════════════════
        // (Add held items here when you have images)
    ]

    // MARK: - Backgrounds

    static let backgrounds: [BackgroundDefinition] = [
        // ═══════════════════════════════════════════════════════════════
        // BACKGROUNDS
        // ═══════════════════════════════════════════════════════════════
        // (Add backgrounds here when you have images)
        // BackgroundDefinition("cozy_room", name: "Cozy Room", price: 25),
        // BackgroundDefinition("night_sky", name: "Night Sky", price: 30),
    ]
}
