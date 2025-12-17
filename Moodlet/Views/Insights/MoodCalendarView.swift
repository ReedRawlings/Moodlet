//
//  MoodCalendarView.swift
//  Moodlet
//

import SwiftUI

struct MoodCalendarView: View {
    let entries: [MoodEntry]
    @Binding var selectedMonth: Date

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    private var daysInMonth: [Date?] {
        let firstDay = calendar.firstDayOfMonth(for: selectedMonth)
        let daysCount = calendar.daysInMonth(for: selectedMonth)
        let firstWeekday = calendar.weekday(for: firstDay)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func moodForDate(_ date: Date) -> Mood? {
        let dayEntries = entries.filter { $0.timestamp.isSameDay(as: date) }
        guard !dayEntries.isEmpty else { return nil }

        // Return the average mood for the day
        let average = dayEntries.map { $0.mood.numericValue }.reduce(0, +) / dayEntries.count
        return Mood.allCases.min { abs($0.numericValue - average) < abs($1.numericValue - average) }
    }

    var body: some View {
        VStack(spacing: MoodletTheme.spacing) {
            // Header
            HStack {
                Text("Mood Calendar")
                    .font(.headline)
                    .foregroundStyle(Color.moodletTextPrimary)

                Spacer()

                monthNavigation
            }

            // Month/Year
            Text(selectedMonth.monthYearString)
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.moodletTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            mood: moodForDate(date),
                            isToday: date.isToday
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }

            // Legend
            moodLegend
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
    }

    // MARK: - Month Navigation

    private var monthNavigation: some View {
        HStack(spacing: MoodletTheme.spacing) {
            Button {
                withAnimation {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(Color.moodletPrimary)
            }

            Button {
                withAnimation {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.moodletPrimary)
            }
            .disabled(calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
        }
    }

    // MARK: - Mood Legend

    private var moodLegend: some View {
        HStack(spacing: MoodletTheme.spacing) {
            ForEach(Mood.allCases) { mood in
                HStack(spacing: 4) {
                    Circle()
                        .fill(mood.color)
                        .frame(width: 8, height: 8)
                    Text(mood.displayName)
                        .font(.caption2)
                        .foregroundStyle(Color.moodletTextTertiary)
                }
            }
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let mood: Mood?
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            if let mood = mood {
                RoundedRectangle(cornerRadius: 4)
                    .fill(mood.color)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.moodletBackground)
            }

            Text("\(calendar.component(.day, from: date))")
                .font(.caption2)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(mood != nil ? .white : Color.moodletTextTertiary)
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isToday ? Color.moodletPrimary : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    MoodCalendarView(entries: [], selectedMonth: .constant(Date()))
        .padding()
        .background(Color.moodletBackground)
}
