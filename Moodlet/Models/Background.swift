//
//  Background.swift
//  Moodlet
//

import Foundation
import SwiftData

@Model
final class Background {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageName: String
    var price: Int
    var isPremiumOnly: Bool
    var requiredStreakMilestone: Int?

    init(
        name: String,
        imageName: String,
        price: Int,
        isPremiumOnly: Bool = false,
        requiredStreakMilestone: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = requiredStreakMilestone
    }
}
