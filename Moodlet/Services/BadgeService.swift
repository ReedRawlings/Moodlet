//
//  BadgeService.swift
//  Moodlet
//

import Foundation

@Observable
class BadgeService {

    func checkAndAwardBadges(
        profile: UserProfile,
        companion: Companion?,
        moodEntryCount: Int
    ) {
        // First Mood badge
        if moodEntryCount >= 1 {
            profile.earnBadge(.firstMood)
        }

        // 3-Day Streak badge
        if profile.longestStreak >= 3 {
            profile.earnBadge(.streak3Day)
        }

        // 5-Day Streak badge
        if profile.longestStreak >= 5 {
            profile.earnBadge(.streak5Day)
        }

        // First Purchase badge
        if !profile.unlockedAccessoryIDs.isEmpty || !profile.unlockedBackgroundIDs.isEmpty {
            profile.earnBadge(.firstPurchase)
        }

        // Dress Up badge
        if let companion = companion, !companion.equippedAccessories.isEmpty {
            profile.earnBadge(.dressUp)
        }
    }

    func checkFirstMoodBadge(profile: UserProfile, moodEntryCount: Int) {
        if moodEntryCount >= 1 {
            profile.earnBadge(.firstMood)
        }
    }

    func checkStreakBadges(profile: UserProfile) {
        if profile.longestStreak >= 3 {
            profile.earnBadge(.streak3Day)
        }
        if profile.longestStreak >= 5 {
            profile.earnBadge(.streak5Day)
        }
    }

    func checkPurchaseBadge(profile: UserProfile) {
        if !profile.unlockedAccessoryIDs.isEmpty || !profile.unlockedBackgroundIDs.isEmpty {
            profile.earnBadge(.firstPurchase)
        }
    }

    func checkDressUpBadge(profile: UserProfile, companion: Companion?) {
        if let companion = companion, !companion.equippedAccessories.isEmpty {
            profile.earnBadge(.dressUp)
        }
    }
}
