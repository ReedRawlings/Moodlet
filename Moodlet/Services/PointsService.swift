//
//  PointsService.swift
//  Moodlet
//

import Foundation
import SwiftData

@Observable
final class PointsService {
    private let maxDailyPointEntries = Constants.Points.maxDailyPointEntries

    func canEarnPoints(on date: Date, entries: [MoodEntry]) -> Bool {
        let todayEntries = entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
        let pointEarningEntries = todayEntries.filter { $0.earnedPoints }
        return pointEarningEntries.count < maxDailyPointEntries
    }

    func calculatePointsForEntry(moodLogged: Bool, tagsAdded: Bool, reflectionWritten: Bool) -> Int {
        var points = 0
        if moodLogged {
            points += Constants.Points.moodLog
        }
        if tagsAdded {
            points += Constants.Points.contextTags
        }
        if reflectionWritten {
            points += Constants.Points.reflection
        }
        return points
    }

    func awardPoints(to profile: UserProfile, amount: Int) {
        profile.totalPoints += amount
    }

    func spendPoints(from profile: UserProfile, amount: Int) -> Bool {
        guard profile.totalPoints >= amount else { return false }
        profile.totalPoints -= amount
        return true
    }

    func checkAndAwardStreakBonus(for profile: UserProfile) -> Int {
        let streak = profile.currentStreak
        var bonus = 0

        // Check each milestone (only award once per milestone reached)
        switch streak {
        case Constants.Streaks.milestone3Day:
            bonus = Constants.Streaks.bonus3Day
        case Constants.Streaks.milestone7Day:
            bonus = Constants.Streaks.bonus7Day
        case Constants.Streaks.milestone14Day:
            bonus = Constants.Streaks.bonus14Day
        case Constants.Streaks.milestone30Day:
            bonus = Constants.Streaks.bonus30Day
        case Constants.Streaks.milestone100Day:
            bonus = Constants.Streaks.bonus100Day
        default:
            break
        }

        if bonus > 0 {
            profile.totalPoints += bonus
        }

        return bonus
    }
}
