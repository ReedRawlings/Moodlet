//
//  DataService.swift
//  Moodlet
//

import Foundation
import SwiftData

@Observable
final class DataService {
    private var modelContext: ModelContext?

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - User Profile

    func getOrCreateUserProfile() -> UserProfile? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try context.fetch(descriptor)
            if let existing = profiles.first {
                return existing
            } else {
                let newProfile = UserProfile()
                context.insert(newProfile)
                return newProfile
            }
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }

    // MARK: - Mood Entries

    func createMoodEntry(
        mood: Mood,
        note: String?,
        activityTags: [String],
        earnedPoints: Bool
    ) -> MoodEntry? {
        guard let context = modelContext else { return nil }

        let entry = MoodEntry(
            mood: mood,
            note: note,
            activityTags: activityTags,
            earnedPoints: earnedPoints
        )
        context.insert(entry)
        return entry
    }

    func getEntries(from startDate: Date, to endDate: Date = Date()) -> [MoodEntry] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= startDate && entry.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }

    func getTodaysEntries() -> [MoodEntry] {
        return getEntries(from: Date().startOfDay)
    }

    func getThisWeeksEntries() -> [MoodEntry] {
        return getEntries(from: Date().startOfWeek)
    }

    func getThisMonthsEntries() -> [MoodEntry] {
        return getEntries(from: Date().startOfMonth)
    }

    // MARK: - Companion

    func getCompanion() -> Companion? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<Companion>()
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Error fetching companion: \(error)")
            return nil
        }
    }

    func createCompanion(
        name: String,
        species: CompanionSpecies,
        pronouns: Pronouns,
        baseColor: String
    ) -> Companion? {
        guard let context = modelContext else { return nil }

        let companion = Companion(
            name: name,
            species: species,
            pronouns: pronouns,
            baseColor: baseColor
        )
        context.insert(companion)
        return companion
    }

    // MARK: - Accessories & Backgrounds

    func getAllAccessories() -> [Accessory] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Accessory>(
            sortBy: [SortDescriptor(\.price)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching accessories: \(error)")
            return []
        }
    }

    func getAllBackgrounds() -> [Background] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Background>(
            sortBy: [SortDescriptor(\.price)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching backgrounds: \(error)")
            return []
        }
    }

    // MARK: - Purchases

    func purchaseAccessory(_ accessory: Accessory, for profile: UserProfile) -> Bool {
        guard profile.totalPoints >= accessory.price else { return false }
        guard !profile.unlockedAccessoryIDs.contains(accessory.id) else { return false }

        profile.totalPoints -= accessory.price
        profile.unlockedAccessoryIDs.append(accessory.id)
        return true
    }

    func purchaseBackground(_ background: Background, for profile: UserProfile) -> Bool {
        guard profile.totalPoints >= background.price else { return false }
        guard !profile.unlockedBackgroundIDs.contains(background.id) else { return false }

        profile.totalPoints -= background.price
        profile.unlockedBackgroundIDs.append(background.id)
        return true
    }

    // MARK: - Delete All Data

    func deleteAllData() {
        guard let context = modelContext else { return }

        do {
            try context.delete(model: MoodEntry.self)
            try context.delete(model: Companion.self)
            try context.delete(model: UserProfile.self)
            try context.delete(model: Accessory.self)
            try context.delete(model: Background.self)
        } catch {
            print("Error deleting data: \(error)")
        }
    }
}
