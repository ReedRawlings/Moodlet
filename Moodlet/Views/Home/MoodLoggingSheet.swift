//
//  MoodLoggingSheet.swift
//  Moodlet
//

import SwiftUI
import SwiftData

// MARK: - Mood Logging Overlay (Centered)

struct MoodLoggingOverlay: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                }

            // Centered card - constrained to content size
            VStack {
                Spacer()
                MoodLoggingSheet(dismiss: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                })
                .frame(maxWidth: 340)
                .background(
                    RoundedRectangle(cornerRadius: MoodletTheme.largeCornerRadius)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.largeCornerRadius))
                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Mood Logging Sheet

struct MoodLoggingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    var dismiss: () -> Void

    @State private var selectedMood: Mood?
    @State private var selectedTags: Set<String> = []
    @State private var journalNote: String = ""
    @State private var currentStep: LoggingStep = .mood
    @State private var journalPrompts: [String] = JournalPrompts.randomPrompts(count: 2)

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    enum LoggingStep {
        case mood
        case activities
        case journal
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content - use ScrollView only for steps that need it
            Group {
                switch currentStep {
                case .mood:
                    moodSelectionView
                        .padding()
                case .activities:
                    ScrollView {
                        activitySelectionView
                            .padding()
                    }
                    .frame(maxHeight: 200)
                case .journal:
                    ScrollView {
                        journalView
                            .padding()
                    }
                    .frame(maxHeight: 300)
                }
            }

            // Action buttons
            actionButtons
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .foregroundStyle(Color.moodletTextSecondary)

            Spacer()

            Text(stepTitle)
                .font(.headline)
                .foregroundStyle(Color.moodletTextPrimary)

            Spacer()

            // Invisible button for balance
            Button("Cancel") {}
                .opacity(0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Step Title

    private var stepTitle: String {
        switch currentStep {
        case .mood: return "How are you feeling?"
        case .activities: return "What's been part of your day?"
        case .journal: return "Mood Journal"
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
        HStack(spacing: MoodletTheme.spacing) {
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
                            .background(Color.moodletPrimary.opacity(0.2))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.moodletPrimary.opacity(0.3), lineWidth: 1)
                            )
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
                        .padding(.vertical, 14)
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
                    .padding(.vertical, 14)
                    .background(selectedMood != nil ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.5))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .disabled(selectedMood == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color : mood.color.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: mood.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : mood.color)
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.moodletTextPrimary : Color.moodletTextSecondary)
            }
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
    MoodLoggingOverlay(isPresented: .constant(true))
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
