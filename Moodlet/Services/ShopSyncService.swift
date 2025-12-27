//
//  ShopSyncService.swift
//  Moodlet
//
//  Syncs the ShopCatalog to the database, adding new items
//  without duplicating existing ones.
//

import Foundation
import SwiftData

@Observable
final class ShopSyncService {

    /// Syncs the shop catalog to the database
    /// - Adds new accessories/backgrounds that don't exist yet
    /// - Does NOT remove or modify existing items (preserves user purchases)
    @MainActor
    func syncCatalog(context: ModelContext) {
        syncAccessories(context: context)
        syncBackgrounds(context: context)
    }

    // MARK: - Private

    @MainActor
    private func syncAccessories(context: ModelContext) {
        // Fetch existing accessory imageNames
        let descriptor = FetchDescriptor<Accessory>()
        let existingAccessories = (try? context.fetch(descriptor)) ?? []
        let existingImageNames = Set(existingAccessories.map { $0.imageName })

        // Add any missing accessories from catalog
        for definition in ShopCatalog.accessories {
            if !existingImageNames.contains(definition.imageName) {
                let accessory = Accessory(
                    name: definition.name,
                    imageName: definition.imageName,
                    category: definition.category,
                    price: definition.price,
                    isPremiumOnly: definition.isPremiumOnly,
                    requiredStreakMilestone: definition.requiredStreakMilestone
                )
                context.insert(accessory)
                print("ShopSync: Added new accessory '\(definition.name)'")
            }
        }
    }

    @MainActor
    private func syncBackgrounds(context: ModelContext) {
        // Fetch existing background imageNames
        let descriptor = FetchDescriptor<Background>()
        let existingBackgrounds = (try? context.fetch(descriptor)) ?? []
        let existingImageNames = Set(existingBackgrounds.map { $0.imageName })

        // Add any missing backgrounds from catalog
        for definition in ShopCatalog.backgrounds {
            if !existingImageNames.contains(definition.imageName) {
                let background = Background(
                    name: definition.name,
                    imageName: definition.imageName,
                    price: definition.price,
                    isPremiumOnly: definition.isPremiumOnly,
                    requiredStreakMilestone: definition.requiredStreakMilestone
                )
                context.insert(background)
                print("ShopSync: Added new background '\(definition.name)'")
            }
        }
    }
}
