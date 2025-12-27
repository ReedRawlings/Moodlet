//
//  WeeklySummaryView.swift
//  Moodlet
//
//  Weekly review summary that awards points for reflection
//

import SwiftUI
import SwiftData

struct WeeklySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var allEntries: [MoodEntry]

    let weekStart: Date

    private var userProfile: UserProfile? { userProfiles.first }

    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
    }

    private var weekEntries: [MoodEntry] {
        allEntries.filter { entry in
            entry.timestamp >= weekStart && entry.timestamp < Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
        }
    }

    private var previousWeekStart: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: weekStart) ?? weekStart
    }

    private var previousWeekEntries: [MoodEntry] {
        allEntries.filter { entry in
            entry.timestamp >= previousWeekStart && entry.timestamp < weekStart
        }
    }

    private var averageMood: Double? {
        guard !weekEntries.isEmpty else { return nil }
        let sum = weekEntries.map { $0.mood.numericValue }.reduce(0, +)
        return Double(sum) / Double(weekEntries.count)
    }

    private var previousAverageMood: Double? {
        guard !previousWeekEntries.isEmpty else { return nil }
        let sum = previousWeekEntries.map { $0.mood.numericValue }.reduce(0, +)
        return Double(sum) / Double(previousWeekEntries.count)
    }

    private var moodTrend: MoodTrend {
        guard let current = averageMood, let previous = previousAverageMood else {
            return .neutral
        }
        let diff = current - previous
        if diff > 0.3 { return .up }
        if diff < -0.3 { return .down }
        return .neutral
    }

    private var dominantMood: Mood? {
        let moodCounts = Dictionary(grouping: weekEntries, by: { $0.mood })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return moodCounts.first?.key
    }

    private var topActivities: [(String, Int)] {
        var activityCounts: [String: Int] = [:]
        for entry in weekEntries {
            for tag in entry.activityTags {
                activityCounts[tag, default: 0] += 1
            }
        }
        return activityCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    private var daysWithEntries: Int {
        let uniqueDays = Set(weekEntries.map { Calendar.current.startOfDay(for: $0.timestamp) })
        return uniqueDays.count
    }

    private var isReviewed: Bool {
        userProfile?.hasReviewedWeek(startingOn: weekStart) ?? false
    }

    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: weekStart)
        let end = formatter.string(from: weekEnd)
        return "\(start) - \(end)"
    }

    enum MoodTrend {
        case up, down, neutral

        var icon: String {
            switch self {
            case .up: return "arrow.up.circle.fill"
            case .down: return "arrow.down.circle.fill"
            case .neutral: return "equal.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .orange
            case .neutral: return .moodletTextSecondary
            }
        }

        var description: String {
            switch self {
            case .up: return "Mood improved"
            case .down: return "Mood dipped"
            case .neutral: return "Mood steady"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Header
                    headerSection

                    if weekEntries.isEmpty {
                        emptyStateView
                    } else {
                        // Stats Grid
                        statsGrid

                        // Mood Trend
                        moodTrendSection

                        // Top Activities
                        if !topActivities.isEmpty {
                            topActivitiesSection
                        }

                        // Daily Breakdown
                        dailyBreakdown
                    }

                    Spacer(minLength: 20)

                    // Review Button
                    reviewButton
                }
                .padding()
            }
            .background(Color.moodletBackground)
            .navigationTitle("Weekly Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(weekDateRange)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.moodletTextPrimary)

            if isReviewed {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.moodletPrimary)
                    Text("Reviewed")
                        .foregroundStyle(Color.moodletPrimary)
                }
                .font(.subheadline)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MoodletTheme.spacing) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.moodletTextTertiary)

            Text("No entries this week")
                .font(.headline)
                .foregroundStyle(Color.moodletTextSecondary)

            Text("Start logging your moods to see weekly insights")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MoodletTheme.spacing) {
            StatBox(
                title: "Entries",
                value: "\(weekEntries.count)",
                icon: "list.bullet.clipboard",
                color: .moodletPrimary
            )

            StatBox(
                title: "Days Active",
                value: "\(daysWithEntries)/7",
                icon: "calendar",
                color: .moodletAccent
            )

            if let mood = dominantMood {
                StatBox(
                    title: "Most Common",
                    value: mood.displayName,
                    icon: mood.icon,
                    color: mood.color
                )
            }

            if let avg = averageMood {
                let closestMood = Mood.allCases.min { abs($0.numericValue - Int(avg.rounded())) < abs($1.numericValue - Int(avg.rounded())) }
                StatBox(
                    title: "Average",
                    value: closestMood?.displayName ?? "—",
                    icon: closestMood?.icon ?? "face.smiling",
                    color: closestMood?.color ?? .moodletTextSecondary
                )
            }
        }
    }

    // MARK: - Mood Trend

    private var moodTrendSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.smallSpacing) {
            Text("Compared to Last Week")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            HStack(spacing: MoodletTheme.spacing) {
                Image(systemName: moodTrend.icon)
                    .font(.title)
                    .foregroundStyle(moodTrend.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(moodTrend.description)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.moodletTextPrimary)

                    if previousWeekEntries.isEmpty {
                        Text("No data from previous week")
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextTertiary)
                    } else {
                        Text("\(weekEntries.count) entries vs \(previousWeekEntries.count) last week")
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
    }

    // MARK: - Top Activities

    private var topActivitiesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.smallSpacing) {
            Text("Top Activities")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            VStack(spacing: 8) {
                ForEach(topActivities, id: \.0) { activityId, count in
                    let activity = ActivityOption.presets.first(where: { $0.id == activityId })
                    HStack {
                        if let activity = activity {
                            Image(systemName: activity.icon)
                                .foregroundStyle(Color.moodletPrimary)
                                .frame(width: 24)
                        }
                        Text(activity?.name ?? activityId)
                            .font(.subheadline)
                            .foregroundStyle(Color.moodletTextPrimary)
                        Spacer()
                        Text("\(count)×")
                            .font(.subheadline)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                }
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
    }

    // MARK: - Daily Breakdown

    private var dailyBreakdown: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.smallSpacing) {
            Text("Daily Overview")
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart)!
                    let dayEntries = weekEntries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
                    let avgMood = dayEntries.isEmpty ? nil : dayEntries.map { $0.mood.numericValue }.reduce(0, +) / dayEntries.count

                    VStack(spacing: 4) {
                        Text(dayAbbreviation(for: date))
                            .font(.caption2)
                            .foregroundStyle(Color.moodletTextTertiary)

                        Circle()
                            .fill(moodColor(for: avgMood))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if dayEntries.isEmpty {
                                    Text("—")
                                        .font(.caption2)
                                        .foregroundStyle(Color.moodletTextTertiary)
                                } else {
                                    Text("\(dayEntries.count)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private func moodColor(for numericValue: Int?) -> Color {
        guard let value = numericValue else {
            return Color.moodletSurface
        }
        return Mood.allCases.first { $0.numericValue == value }?.color ?? .moodletTextTertiary
    }

    // MARK: - Review Button

    private var reviewButton: some View {
        Button {
            userProfile?.markWeekReviewed(startingOn: weekStart)
            dismiss()
        } label: {
            HStack {
                if isReviewed {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Already Reviewed")
                } else {
                    Image(systemName: "star.fill")
                    Text("Complete Review (+\(Constants.Points.weeklyReview) pts)")
                }
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isReviewed ? Color.moodletSurface : Color.moodletPrimary)
            .foregroundStyle(isReviewed ? Color.moodletTextSecondary : .white)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
        .disabled(isReviewed)
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.moodletTextPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
    }
}

// MARK: - Weekly Summary Card (for Home/Insights)

struct WeeklySummaryCard: View {
    @Query private var userProfiles: [UserProfile]
    @State private var showingSummary = false

    private var userProfile: UserProfile? { userProfiles.first }

    private var unreviewedWeek: Date? {
        userProfile?.unreviewedWeekStart()
    }

    private var weekDateRange: String {
        guard let weekStart = unreviewedWeek else { return "" }
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }

    var body: some View {
        if let weekStart = unreviewedWeek {
            Button {
                showingSummary = true
            } label: {
                HStack(spacing: MoodletTheme.spacing) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundStyle(Color.moodletAccent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Review Available")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.moodletTextPrimary)

                        Text(weekDateRange)
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("+\(Constants.Points.weeklyReview)")
                            .font(.caption)
                            .fontWeight(.bold)
                        Image(systemName: "star.fill")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.moodletAccent)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextTertiary)
                }
                .padding()
                .background(Color.moodletSurface)
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingSummary) {
                WeeklySummaryView(weekStart: weekStart)
            }
        }
    }
}

#Preview {
    WeeklySummaryView(weekStart: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        .modelContainer(for: [
            UserProfile.self,
            MoodEntry.self
        ], inMemory: true)
}
