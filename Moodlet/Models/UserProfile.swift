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
    var notificationsEnabled: Bool
    var isPremium: Bool
    var premiumExpirationDate: Date?

    var unlockedAccessoryIDs: [UUID]
    var unlockedBackgroundIDs: [UUID]
    var unlockedSpecies: [String]
    var earnedBadges: [String: Date]
    var reviewedWeekStartDates: [Date]  // Tracks which weeks have been reviewed for points

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
        self.notificationsEnabled = false
        self.isPremium = false
        self.premiumExpirationDate = nil
        self.unlockedAccessoryIDs = []
        self.unlockedBackgroundIDs = []
        self.unlockedSpecies = [CompanionSpecies.cat.rawValue]
        self.earnedBadges = [:]
        self.reviewedWeekStartDates = []
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

    // MARK: - Weekly Review

    /// Returns the start of the week (Sunday) for a given date
    static func weekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Check if a specific week has been reviewed
    func hasReviewedWeek(startingOn weekStart: Date) -> Bool {
        let calendar = Calendar.current
        return reviewedWeekStartDates.contains { reviewedDate in
            calendar.isDate(reviewedDate, inSameDayAs: weekStart)
        }
    }

    /// Mark a week as reviewed and award points
    func markWeekReviewed(startingOn weekStart: Date) {
        guard !hasReviewedWeek(startingOn: weekStart) else { return }
        reviewedWeekStartDates.append(weekStart)
        totalPoints += Constants.Points.weeklyReview
    }

    /// Get the most recent complete week that hasn't been reviewed
    func unreviewedWeekStart() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekStart = Self.weekStart(for: now)

        // Check the previous week (last week is the most recent complete week)
        guard let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) else {
            return nil
        }

        // Only return if not already reviewed
        if !hasReviewedWeek(startingOn: lastWeekStart) {
            return lastWeekStart
        }

        return nil
    }
}
