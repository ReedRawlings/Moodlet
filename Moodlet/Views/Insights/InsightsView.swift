//
//  InsightsView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

// MARK: - Time Period

enum TimePeriod: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case night = "Night"

    var id: String { rawValue }

    var timeRange: String {
        switch self {
        case .morning: return "6am - 12pm"
        case .afternoon: return "12pm - 6pm"
        case .night: return "6pm - 6am"
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .night: return "moon.fill"
        }
    }

    static func from(date: Date) -> TimePeriod {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6...11: return .morning
        case 12...17: return .afternoon
        default: return .night // 18-23 and 0-5
        }
    }
}

// MARK: - Insights View

struct InsightsView: View {
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var entries: [MoodEntry]

    @State private var selectedTimeframe: Timeframe = .month
    @State private var selectedMonth: Date = Date()

    enum Timeframe: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var id: String { rawValue }
    }

    // MARK: - Computed Properties

    private var last30DaysEntries: [MoodEntry] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= thirtyDaysAgo }
    }

    private var moodCounts: [(Mood, Int)] {
        var counts: [Mood: Int] = [:]
        for entry in last30DaysEntries {
            counts[entry.mood, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
    }

    private var maxMoodCount: Int {
        moodCounts.first?.1 ?? 1
    }

    private var moodActivityRelationships: [(Mood, Int, [(String, Int)])] {
        var moodActivities: [Mood: [String: Int]] = [:]
        for entry in last30DaysEntries {
            for tag in entry.activityTags {
                moodActivities[entry.mood, default: [:]][tag, default: 0] += 1
            }
        }
        return moodCounts.compactMap { mood, count in
            let activities = moodActivities[mood] ?? [:]
            let sortedActivities = activities.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
            return (mood, count, Array(sortedActivities))
        }
    }

    private var moodPeopleRelationships: [(Mood, Int, [(String, Int)])] {
        var moodPeople: [Mood: [String: Int]] = [:]
        for entry in last30DaysEntries {
            for tag in entry.peopleTags {
                moodPeople[entry.mood, default: [:]][tag, default: 0] += 1
            }
        }
        return moodCounts.compactMap { mood, count in
            let people = moodPeople[mood] ?? [:]
            guard !people.isEmpty else { return nil }
            let sortedPeople = people.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
            return (mood, count, Array(sortedPeople))
        }
    }

    private var moodsByTimeOfDay: [TimePeriod: [(Mood, Int)]] {
        var timeData: [TimePeriod: [Mood: Int]] = [:]
        for entry in last30DaysEntries {
            let period = TimePeriod.from(date: entry.timestamp)
            timeData[period, default: [:]][entry.mood, default: 0] += 1
        }
        return timeData.mapValues { moodCounts in
            moodCounts.sorted { $0.value > $1.value }
        }
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Timeframe picker
                    timeframePicker

                    // Mood Calendar (Year in Pixels)
                    MoodCalendarView(entries: entries, selectedMonth: $selectedMonth)

                    // Mood Overview (Last 30 Days)
                    if !moodCounts.isEmpty {
                        moodOverviewSection
                    }

                    // Mood & Activities
                    if !moodActivityRelationships.isEmpty {
                        moodActivitiesSection
                    }

                    // Mood & People
                    if !moodPeopleRelationships.isEmpty {
                        moodPeopleSection
                    }

                    // Moods by Time of Day
                    if !moodsByTimeOfDay.isEmpty {
                        moodsByTimeSection
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

    // MARK: - Mood Overview Section

    private var moodOverviewSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Most Common Moods")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            Text("Last 30 days")
                .font(.caption)
                .foregroundStyle(Color.moodletTextSecondary)

            VStack(spacing: MoodletTheme.smallSpacing) {
                ForEach(moodCounts, id: \.0) { mood, count in
                    MoodCountRow(
                        mood: mood,
                        count: count,
                        maxCount: maxMoodCount
                    )
                }
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
    }

    // MARK: - Mood & Activities Section

    private var moodActivitiesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Mood & Activities")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            VStack(spacing: MoodletTheme.smallSpacing) {
                ForEach(moodActivityRelationships, id: \.0) { mood, count, activities in
                    MoodActivityCard(
                        mood: mood,
                        count: count,
                        activities: activities
                    )
                }
            }
        }
    }

    // MARK: - Mood & People Section

    private var moodPeopleSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Mood & People")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            VStack(spacing: MoodletTheme.smallSpacing) {
                ForEach(moodPeopleRelationships, id: \.0) { mood, count, people in
                    MoodPeopleCard(
                        mood: mood,
                        count: count,
                        people: people
                    )
                }
            }
        }
    }

    // MARK: - Moods by Time Section

    private var moodsByTimeSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Moods by Time of Day")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            HStack(alignment: .top, spacing: MoodletTheme.smallSpacing) {
                ForEach(TimePeriod.allCases) { period in
                    TimeOfDayCard(
                        period: period,
                        moods: moodsByTimeOfDay[period] ?? []
                    )
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
}

// MARK: - Mood Count Row

struct MoodCountRow: View {
    let mood: Mood
    let count: Int
    let maxCount: Int

    private var barWidth: CGFloat {
        guard maxCount > 0 else { return 0 }
        return CGFloat(count) / CGFloat(maxCount)
    }

    var body: some View {
        HStack(spacing: MoodletTheme.spacing) {
            // Mood icon and name
            HStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .foregroundStyle(mood.color)
                    .frame(width: 20)

                Text(mood.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextPrimary)
            }
            .frame(width: 90, alignment: .leading)

            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.moodletBackground)
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(mood.color)
                        .frame(width: geometry.size.width * barWidth, height: 16)
                }
            }
            .frame(height: 16)

            // Count
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.moodletTextSecondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Mood Activity Card

struct MoodActivityCard: View {
    let mood: Mood
    let count: Int
    let activities: [(String, Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Mood header
            HStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .foregroundStyle(mood.color)

                Text(mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                Text("(\(count))")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextSecondary)

                Spacer()
            }

            // Activities
            if activities.isEmpty {
                Text("No activities logged")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(activities, id: \.0) { activity, activityCount in
                        ActivityPill(name: activity, count: activityCount)
                    }
                }
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

// MARK: - Activity Pill

struct ActivityPill: View {
    let name: String
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            if let activity = ActivityOption.presets.first(where: { $0.id == name }) {
                Image(systemName: activity.icon)
                    .font(.system(size: 10))
            } else if let tag = DefaultActivityTag(rawValue: name) {
                Image(systemName: tag.icon)
                    .font(.system(size: 10))
            }
            Text(ActivityOption.presets.first(where: { $0.id == name })?.name ?? name)
                .font(.caption)
            Text("(\(count))")
                .font(.caption2)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.moodletBackground)
        .clipShape(Capsule())
    }
}

// MARK: - Mood People Card

struct MoodPeopleCard: View {
    let mood: Mood
    let count: Int
    let people: [(String, Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Mood header
            HStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .foregroundStyle(mood.color)

                Text(mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                Text("(\(count))")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextSecondary)

                Spacer()
            }

            // People
            FlowLayout(spacing: 6) {
                ForEach(people, id: \.0) { personId, personCount in
                    PeoplePill(personId: personId, count: personCount)
                }
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

// MARK: - People Pill

struct PeoplePill: View {
    let personId: String
    let count: Int

    private var personOption: PeopleOption? {
        PeopleOption.presets.first(where: { $0.id == personId })
    }

    var body: some View {
        HStack(spacing: 4) {
            if let person = personOption {
                Image(systemName: person.icon)
                    .font(.system(size: 10))
            }
            Text(personOption?.name ?? personId)
                .font(.caption)
            Text("(\(count))")
                .font(.caption2)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.moodletBackground)
        .clipShape(Capsule())
    }
}

// MARK: - Time of Day Card

struct TimeOfDayCard: View {
    let period: TimePeriod
    let moods: [(Mood, Int)]

    var body: some View {
        VStack(spacing: MoodletTheme.smallSpacing) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: period.icon)
                    .font(.title3)
                    .foregroundStyle(Color.moodletPrimary)

                Text(period.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                Text(period.timeRange)
                    .font(.caption2)
                    .foregroundStyle(Color.moodletTextTertiary)
            }

            Divider()

            // Moods list
            if moods.isEmpty {
                Text("No data")
                    .font(.caption2)
                    .foregroundStyle(Color.moodletTextTertiary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 6) {
                    ForEach(moods.prefix(3), id: \.0) { mood, count in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(mood.color)
                                .frame(width: 8, height: 8)

                            Text("\(count)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.moodletTextSecondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
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
                let activityNames = entry.activityTags.map { id in
                    ActivityOption.presets.first(where: { $0.id == id })?.name ?? id
                }
                Text(activityNames.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextSecondary)
            }

            if !entry.peopleTags.isEmpty {
                let peopleNames = entry.peopleTags.map { id in
                    PeopleOption.presets.first(where: { $0.id == id })?.name ?? id
                }
                Text("With: " + peopleNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)
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
