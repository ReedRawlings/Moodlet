//
//  InsightsView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var entries: [MoodEntry]

    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedMonth: Date = Date()

    enum Timeframe: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var id: String { rawValue }
    }

    private var filteredEntries: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return entries.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return entries.filter { $0.timestamp >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return entries.filter { $0.timestamp >= yearAgo }
        }
    }

    private var averageMood: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        let total = filteredEntries.map { Double($0.mood.numericValue) }.reduce(0, +)
        return total / Double(filteredEntries.count)
    }

    private var mostCommonTags: [(String, Int)] {
        var tagCounts: [String: Int] = [:]
        for entry in filteredEntries {
            for tag in entry.activityTags {
                tagCounts[tag, default: 0] += 1
            }
        }
        return tagCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Timeframe picker
                    timeframePicker

                    // Mood Calendar (Year in Pixels)
                    MoodCalendarView(entries: entries, selectedMonth: $selectedMonth)

                    // Stats Summary
                    statsSummary

                    // Top Activities
                    if !mostCommonTags.isEmpty {
                        topActivitiesSection
                    }

                    // Recent Entries
                    recentEntriesSection
                }
                .padding()
            }
            .background(Color.moodletBackground)
            .navigationTitle("Insights")
        }
    }

    // MARK: - Timeframe Picker

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Stats Summary

    private var statsSummary: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            HStack(spacing: MoodletTheme.spacing) {
                InsightStatCard(
                    title: "Entries",
                    value: "\(filteredEntries.count)",
                    icon: "list.bullet",
                    color: .moodletPrimary
                )

                InsightStatCard(
                    title: "Avg Mood",
                    value: String(format: "%.1f", averageMood),
                    icon: "chart.line.uptrend.xyaxis",
                    color: moodColorForValue(averageMood)
                )

                InsightStatCard(
                    title: "With Notes",
                    value: "\(filteredEntries.filter { $0.note != nil }.count)",
                    icon: "note.text",
                    color: .moodletAccent
                )
            }
        }
    }

    // MARK: - Top Activities

    private var topActivitiesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Top Activities")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            VStack(spacing: MoodletTheme.smallSpacing) {
                ForEach(mostCommonTags, id: \.0) { tag, count in
                    HStack {
                        if let activityTag = DefaultActivityTag(rawValue: tag) {
                            Image(systemName: activityTag.icon)
                                .foregroundStyle(Color.moodletPrimary)
                                .frame(width: 24)
                        }

                        Text(tag)
                            .foregroundStyle(Color.moodletTextPrimary)

                        Spacer()

                        Text("\(count) times")
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                    .padding()
                    .background(Color.moodletSurface)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
                }
            }
        }
    }

    // MARK: - Recent Entries

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Recent Entries")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            if filteredEntries.isEmpty {
                Text("No entries yet. Start logging to see insights!")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.moodletSurface)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            } else {
                ForEach(filteredEntries.prefix(5)) { entry in
                    InsightEntryRow(entry: entry)
                }
            }
        }
    }

    // MARK: - Helpers

    private func moodColorForValue(_ value: Double) -> Color {
        switch value {
        case 4.5...: return Mood.happy.color
        case 3.5..<4.5: return Mood.content.color
        case 2.5..<3.5: return Mood.neutral.color
        case 1.5..<2.5: return Mood.annoyed.color
        default: return Mood.sad.color
        }
    }
}

// MARK: - Insight Stat Card

struct InsightStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.moodletTextPrimary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

// MARK: - Insight Entry Row

struct InsightEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(entry.mood.color)
                    .frame(width: 10, height: 10)

                Text(entry.mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                Spacer()

                Text(entry.timestamp.relativeDescription)
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)

                Text(entry.timestamp.timeString)
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)
            }

            if !entry.activityTags.isEmpty {
                Text(entry.activityTags.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextSecondary)
            }

            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
