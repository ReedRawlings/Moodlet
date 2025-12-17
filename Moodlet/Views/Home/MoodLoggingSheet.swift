//
//  MoodLoggingSheet.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct MoodLoggingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]

    @State private var selectedMood: Mood?
    @State private var selectedTags: Set<String> = []
    @State private var journalNote: String = ""
    @State private var currentStep: LoggingStep = .mood
    @State private var journalPrompts: [String] = JournalPrompts.randomPrompts()

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    enum LoggingStep {
        case mood
        case activities
        case journal
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                // Content
                ScrollView {
                    VStack(spacing: MoodletTheme.largeSpacing) {
                        switch currentStep {
                        case .mood:
                            moodSelectionView
                        case .activities:
                            activitySelectionView
                        case .journal:
                            journalView
                        }
                    }
                    .padding()
                }

                // Action buttons
                actionButtons
            }
            .background(Color.moodletBackground)
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.moodletTextSecondary)
                }
            }
        }
    }

    // MARK: - Step Title

    private var stepTitle: String {
        switch currentStep {
        case .mood: return "How are you feeling?"
        case .activities: return "What's been part of your day?"
        case .journal: return "Anything to add?"
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(index <= currentStep.rawValue ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Mood Selection

    private var moodSelectionView: some View {
        VStack(spacing: MoodletTheme.largeSpacing) {
            Text("Tap to select your mood")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: MoodletTheme.spacing) {
                ForEach(Mood.allCases) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
    }

    // MARK: - Activity Selection

    private var activitySelectionView: some View {
        VStack(spacing: MoodletTheme.largeSpacing) {
            Text("Select all that apply (optional)")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)

            FlowLayout(spacing: MoodletTheme.smallSpacing) {
                ForEach(DefaultActivityTag.allCases) { tag in
                    ActivityTagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag.rawValue)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedTags.contains(tag.rawValue) {
                                selectedTags.remove(tag.rawValue)
                            } else {
                                selectedTags.insert(tag.rawValue)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Journal View

    private var journalView: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Reflection (optional, +2 points)")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)

            // Prompts
            VStack(alignment: .leading, spacing: MoodletTheme.smallSpacing) {
                Text("Prompts to consider:")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)

                ForEach(journalPrompts, id: \.self) { prompt in
                    Button {
                        if journalNote.isEmpty {
                            journalNote = prompt + " "
                        }
                    } label: {
                        Text(prompt)
                            .font(.caption)
                            .foregroundStyle(Color.moodletPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.moodletPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            // Text editor
            TextEditor(text: $journalNote)
                .frame(minHeight: 120)
                .padding(MoodletTheme.smallSpacing)
                .background(Color.moodletSurface)
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                        .stroke(Color.moodletPrimary.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: MoodletTheme.spacing) {
            if currentStep != .mood {
                Button {
                    withAnimation {
                        goBack()
                    }
                } label: {
                    Text("Back")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moodletSurface)
                        .foregroundStyle(Color.moodletTextPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                }
            }

            Button {
                withAnimation {
                    if currentStep == .journal {
                        saveEntry()
                    } else {
                        goNext()
                    }
                }
            } label: {
                Text(currentStep == .journal ? "Save" : (currentStep == .activities ? "Next" : "Continue"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedMood != nil ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.5))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .disabled(selectedMood == nil)
        }
        .padding()
        .background(Color.moodletBackground)
    }

    // MARK: - Navigation

    private func goNext() {
        switch currentStep {
        case .mood:
            currentStep = .activities
        case .activities:
            currentStep = .journal
        case .journal:
            break
        }
    }

    private func goBack() {
        switch currentStep {
        case .mood:
            break
        case .activities:
            currentStep = .mood
        case .journal:
            currentStep = .activities
        }
    }

    // MARK: - Save Entry

    private func saveEntry() {
        guard let mood = selectedMood else { return }

        let entry = MoodEntry(
            mood: mood,
            note: journalNote.isEmpty ? nil : journalNote,
            activityTags: Array(selectedTags),
            earnedPoints: true
        )

        modelContext.insert(entry)

        // Update points
        if var profile = userProfile {
            var points = Constants.Points.moodLog
            if !selectedTags.isEmpty {
                points += Constants.Points.contextTags
            }
            if !journalNote.isEmpty {
                points += Constants.Points.reflection
            }
            profile.totalPoints += points
        }

        dismiss()
    }
}

// MARK: - Logging Step Extension

extension MoodLoggingSheet.LoggingStep {
    var rawValue: Int {
        switch self {
        case .mood: return 0
        case .activities: return 1
        case .journal: return 2
        }
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color : mood.color.opacity(0.2))
                        .frame(width: 64, height: 64)

                    Image(systemName: mood.icon)
                        .font(.title)
                        .foregroundStyle(isSelected ? .white : mood.color)
                }

                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.moodletTextPrimary : Color.moodletTextSecondary)
            }
            .padding()
            .background(isSelected ? Color.moodletSurface : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Tag Chip

struct ActivityTagChip: View {
    let tag: DefaultActivityTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tag.icon)
                    .font(.caption)
                Text(tag.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.moodletPrimary : Color.moodletSurface)
            .foregroundStyle(isSelected ? .white : Color.moodletTextPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.moodletPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    MoodLoggingSheet()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
