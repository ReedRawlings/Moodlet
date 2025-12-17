//
//  UserProfile.swift
//  Moodlet
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastLogDate: Date?
    var streakGraceUsed: Bool
    var onboardingCompleted: Bool
    var onboardingStep: Int
    var notificationTimes: [Date]
    var isPremium: Bool
    var premiumExpirationDate: Date?

    var unlockedAccessoryIDs: [UUID]
    var unlockedBackgroundIDs: [UUID]
    var unlockedSpecies: [String]

    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastLogDate = nil
        self.streakGraceUsed = false
        self.onboardingCompleted = false
        self.onboardingStep = 0
        self.notificationTimes = []
        self.isPremium = false
        self.premiumExpirationDate = nil
        self.unlockedAccessoryIDs = []
        self.unlockedBackgroundIDs = []
        self.unlockedSpecies = [CompanionSpecies.cat.rawValue]
    }

    func hasUnlockedSpecies(_ species: CompanionSpecies) -> Bool {
        unlockedSpecies.contains(species.rawValue)
    }

    func hasUnlockedAccessory(_ accessoryID: UUID) -> Bool {
        unlockedAccessoryIDs.contains(accessoryID)
    }

    func hasUnlockedBackground(_ backgroundID: UUID) -> Bool {
        unlockedBackgroundIDs.contains(backgroundID)
    }
}
