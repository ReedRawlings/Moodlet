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

                    // Quick Log Button
                    quickLogButton

                    // Today's Entries
                    if !todaysEntries.isEmpty {
                        todaysEntriesSection
                    }

                    // Stats Overview
                    statsOverview
                }
                .padding()
            }
            .background(Color.moodletBackground)
            .navigationTitle("Moodlet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    pointsBadge
                }
            }
        }
    }

    // MARK: - Companion Section

    private var companionSection: some View {
        VStack(spacing: MoodletTheme.spacing) {
            CompanionView(
                companion: companion,
                moodTrend: recentMoodTrend
            )
            .frame(height: 280)

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
        .glassEffect(.regular.interactive())
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

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: MoodletTheme.spacing) {
            StatCard(
                title: "Streak",
                value: "\(userProfile?.currentStreak ?? 0)",
                subtitle: "days",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "Today",
                value: "\(todaysEntries.count)",
                subtitle: "entries",
                icon: "checkmark.circle.fill",
                color: .moodletPrimary
            )
        }
    }

    // MARK: - Points Badge

    private var pointsBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(Color.moodletAccent)
            Text("\(userProfile?.totalPoints ?? 0)")
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.moodletAccent.opacity(0.15))
        .clipShape(Capsule())
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
