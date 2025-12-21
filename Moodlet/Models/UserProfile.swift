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
    var earnedBadges: [String: Date]

    // Check-in customization
    var selectedEmotionIds: [String]
    var selectedActivityIds: [String]
    var selectedPeopleIds: [String]
    var customActivitiesData: Data?
    var customPeopleData: Data?

    // Computed properties for custom items
    var customActivities: [ActivityOption] {
        get {
            guard let data = customActivitiesData else { return [] }
            return (try? JSONDecoder().decode([ActivityOption].self, from: data)) ?? []
        }
        set {
            customActivitiesData = try? JSONEncoder().encode(newValue)
        }
    }

    var customPeople: [PeopleOption] {
        get {
            guard let data = customPeopleData else { return [] }
            return (try? JSONDecoder().decode([PeopleOption].self, from: data)) ?? []
        }
        set {
            customPeopleData = try? JSONEncoder().encode(newValue)
        }
    }

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
        self.earnedBadges = [:]
        self.selectedEmotionIds = EmotionOption.defaultSelection
        self.selectedActivityIds = ActivityOption.defaultSelection
        self.selectedPeopleIds = PeopleOption.defaultSelection
        self.customActivitiesData = nil
        self.customPeopleData = nil
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

    func hasBadge(_ badge: Badge) -> Bool {
        earnedBadges[badge.rawValue] != nil
    }

    func earnBadge(_ badge: Badge) {
        guard !hasBadge(badge) else { return }
        earnedBadges[badge.rawValue] = Date()
    }

    func badgeEarnedDate(_ badge: Badge) -> Date? {
        earnedBadges[badge.rawValue]
    }
}
