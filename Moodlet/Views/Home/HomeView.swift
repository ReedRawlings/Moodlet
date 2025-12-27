//
//  HomeView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var companions: [Companion]
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var recentEntries: [MoodEntry]

    @Binding var showMoodLogging: Bool
    @State private var showWardrobe = false

    private var companion: Companion? {
        companions.first
    }

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var todaysEntries: [MoodEntry] {
        recentEntries.filter { $0.timestamp.isToday }
    }

    private var recentMoodTrend: Mood? {
        let lastThreeDays = recentEntries.filter {
            $0.timestamp.daysBetween(Date()) <= 3
        }
        guard !lastThreeDays.isEmpty else { return nil }

        let average = lastThreeDays.map { $0.mood.numericValue }.reduce(0, +) / lastThreeDays.count
        return Mood.allCases.min { abs($0.numericValue - average) < abs($1.numericValue - average) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Companion Section
                    companionSection

                    // Weekly Summary Card (if available)
                    WeeklySummaryCard()

                    // Quick Log Button
                    quickLogButton

                    // Today's Entries
                    if !todaysEntries.isEmpty {
                        todaysEntriesSection
                    }
                }
                .padding()
            }
            .background(Color.moodletBackground)
            .navigationTitle("Moodlet")
        }
    }

    // MARK: - Companion Section

    private var companionSection: some View {
        VStack(spacing: MoodletTheme.spacing) {
            ZStack(alignment: .bottomTrailing) {
                CompanionView(
                    companion: companion,
                    moodTrend: recentMoodTrend,
                    points: userProfile?.totalPoints ?? 0,
                    streak: userProfile?.currentStreak ?? 0,
                    entries: todaysEntries.count
                )
                .frame(height: 280)

                // Wardrobe button
                if companion != nil {
                    Button {
                        showWardrobe = true
                    } label: {
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.moodletPrimary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .padding(12)
                }
            }

            if let companion = companion {
                Text(companion.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.moodletTextPrimary)

                if let mood = recentMoodTrend {
                    Text("\(companion.pronouns.subject.capitalized) \(companion.pronouns.subject == "they" ? "seem" : "seems") \(mood.displayName.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)
                }
            } else {
                Text("No companion yet")
                    .font(.title2)
                    .foregroundStyle(Color.moodletTextSecondary)
            }
        }
        .sheet(isPresented: $showWardrobe) {
            WardrobeView()
        }
    }

    // MARK: - Quick Log Button

    private var quickLogButton: some View {
        Button {
            showMoodLogging = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("How are you feeling?")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.moodletPrimary)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
    }

    // MARK: - Today's Entries

    private var todaysEntriesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.smallSpacing) {
            Text("Today")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            ForEach(todaysEntries) { entry in
                MoodEntryRow(entry: entry)
            }
        }
    }

}

// MARK: - Supporting Views

struct MoodEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: MoodletTheme.spacing) {
            Circle()
                .fill(entry.mood.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                if !entry.activityTags.isEmpty {
                    Text(entry.activityTags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextSecondary)
                }
            }

            Spacer()

            Text(entry.timestamp.timeString)
                .font(.caption)
                .foregroundStyle(Color.moodletTextTertiary)
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: MoodletTheme.smallSpacing) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.moodletTextPrimary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
    }
}

#Preview {
    HomeView(showMoodLogging: .constant(false))
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
