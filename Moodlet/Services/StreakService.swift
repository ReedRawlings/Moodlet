//
//  StreakService.swift
//  Moodlet
//

import Foundation

@Observable
final class StreakService {
    private let gracePeriodDays = Constants.Streaks.gracePeriodDays

    func updateStreak(for profile: UserProfile, newEntryDate: Date) {
        guard let lastLog = profile.lastLogDate else {
            // First ever entry
            profile.currentStreak = 1
            profile.lastLogDate = newEntryDate
            return
        }

        let calendar = Calendar.current
        let daysSinceLastLog = calendar.dateComponents([.day], from: lastLog.startOfDay, to: newEntryDate.startOfDay).day ?? 0

        switch daysSinceLastLog {
        case 0:
            // Same day, no streak change
            break
        case 1:
            // Consecutive day
            profile.currentStreak += 1
            profile.streakGraceUsed = false
        case 2:
            // Within grace period
            if !profile.streakGraceUsed {
                profile.currentStreak += 1
                profile.streakGraceUsed = true
            } else {
                profile.currentStreak = 1
                profile.streakGraceUsed = false
            }
        default:
            // Streak broken
            profile.currentStreak = 1
            profile.streakGraceUsed = false
        }

        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        profile.lastLogDate = newEntryDate
    }

    func isStreakAtRisk(for profile: UserProfile) -> Bool {
        guard let lastLog = profile.lastLogDate else { return false }

        let calendar = Calendar.current
        let daysSinceLastLog = calendar.dateComponents([.day], from: lastLog.startOfDay, to: Date().startOfDay).day ?? 0

        // Streak is at risk if it's been 1 day and grace hasn't been used
        return daysSinceLastLog == 1 && !profile.streakGraceUsed
    }

    func streakMilestoneReached(for profile: UserProfile) -> Int? {
        let milestones = [
            Constants.Streaks.milestone3Day,
            Constants.Streaks.milestone7Day,
            Constants.Streaks.milestone14Day,
            Constants.Streaks.milestone30Day,
            Constants.Streaks.milestone100Day
        ]

        if milestones.contains(profile.currentStreak) {
            return profile.currentStreak
        }
        return nil
    }

    func nextMilestone(for profile: UserProfile) -> Int {
        let milestones = [
            Constants.Streaks.milestone3Day,
            Constants.Streaks.milestone7Day,
            Constants.Streaks.milestone14Day,
            Constants.Streaks.milestone30Day,
            Constants.Streaks.milestone100Day
        ]

        for milestone in milestones {
            if profile.currentStreak < milestone {
                return milestone
            }
        }

        return profile.currentStreak + 1
    }

    func daysUntilNextMilestone(for profile: UserProfile) -> Int {
        return nextMilestone(for: profile) - profile.currentStreak
    }
}
