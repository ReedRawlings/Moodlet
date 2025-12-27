//
//  MoodLoggingSheet.swift
//  Moodlet
//

import SwiftUI
import SwiftData

// MARK: - Mood Logging Overlay (Centered)

struct MoodLoggingOverlay: View {
    @Binding var isPresented: Bool
    var preSelectedEmotion: EmotionOption?
    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                        onDismiss?()
                    }
                }

            // Centered card - constrained to content size
            VStack {
                Spacer()
                MoodLoggingSheet(
                    preSelectedEmotion: preSelectedEmotion,
                    dismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                            onDismiss?()
                        }
                    }
                )
                .frame(maxWidth: 380)
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
    @Query private var moodEntries: [MoodEntry]
    @Query private var companions: [Companion]

    var preSelectedEmotion: EmotionOption?
    var dismiss: () -> Void

    @State private var selectedEmotion: EmotionOption?
    @State private var selectedTags: Set<String> = []
    @State private var selectedPeople: Set<String> = []
    @State private var journalNote: String = ""
    @State private var currentStep: LoggingStep = .moodAndActivities
    @State private var journalPrompts: [String] = JournalPrompts.randomPrompts(count: 2)
    @State private var hasAppliedPreSelection = false

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var companion: Companion? {
        companions.first
    }

    private let badgeService = BadgeService()
    private let streakService = StreakService()

    // Get filtered emotions based on user preferences
    private var availableEmotions: [EmotionOption] {
        guard let profile = userProfile else {
            return EmotionOption.presets.filter { EmotionOption.defaultSelection.contains($0.id) }
        }
        return EmotionOption.presets.filter { profile.selectedEmotionIds.contains($0.id) }
    }

    // Get filtered activities based on user preferences
    private var availableActivities: [ActivityOption] {
        guard let profile = userProfile else {
            return ActivityOption.presets
        }
        let presets = ActivityOption.presets.filter { profile.selectedActivityIds.contains($0.id) }
        let custom = profile.customActivities.filter { profile.selectedActivityIds.contains($0.id) }
        return presets + custom
    }

    // Get filtered people options based on user preferences
    private var availablePeople: [PeopleOption] {
        guard let profile = userProfile else {
            return PeopleOption.presets
        }
        let presets = PeopleOption.presets.filter { profile.selectedPeopleIds.contains($0.id) }
        let custom = profile.customPeople.filter { profile.selectedPeopleIds.contains($0.id) }
        return presets + custom
    }

    enum LoggingStep {
        case moodAndActivities
        case journal
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content - different sizing for each step
            switch currentStep {
            case .moodAndActivities:
                ScrollView {
                    moodAndActivitiesView
                        .padding()
                }
                .frame(height: 400)
            case .journal:
                ScrollView {
                    journalView
                        .padding()
                }
                .frame(height: 280)
            }

            // Action buttons
            actionButtons
        }
        .onAppear {
            applyPreSelectedEmotion()
        }
    }

    /// Apply pre-selected emotion from notification quick action
    private func applyPreSelectedEmotion() {
        guard !hasAppliedPreSelection,
              let emotion = preSelectedEmotion else { return }

        hasAppliedPreSelection = true
        selectedEmotion = emotion
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
        case .moodAndActivities: return "How are you feeling?"
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

    // MARK: - Mood and Activities Combined View

    private var moodAndActivitiesView: some View {
        VStack(spacing: MoodletTheme.largeSpacing) {
            // Emotion Selection - horizontal scroll for single line
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MoodletTheme.spacing) {
                    ForEach(availableEmotions) { emotion in
                        EmotionButton(
                            emotion: emotion,
                            isSelected: selectedEmotion?.id == emotion.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedEmotion = emotion
                            }
                        }
                    }
                }
                .padding(.horizontal, MoodletTheme.smallSpacing)
            }

            // People Selection
            VStack(spacing: MoodletTheme.spacing) {
                Text("Who are you with?")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)

                FlowLayout(spacing: MoodletTheme.smallSpacing) {
                    ForEach(availablePeople) { person in
                        PeopleTagChip(
                            person: person,
                            isSelected: selectedPeople.contains(person.id)
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedPeople.contains(person.id) {
                                    selectedPeople.remove(person.id)
                                } else {
                                    selectedPeople.insert(person.id)
                                }
                            }
                        }
                    }
                }
            }

            // Activity Selection
            VStack(spacing: MoodletTheme.spacing) {
                Text("What's been part of your day?")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)

                FlowLayout(spacing: MoodletTheme.smallSpacing) {
                    ForEach(availableActivities) { activity in
                        CustomActivityTagChip(
                            activity: activity,
                            isSelected: selectedTags.contains(activity.id)
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedTags.contains(activity.id) {
                                    selectedTags.remove(activity.id)
                                } else {
                                    selectedTags.insert(activity.id)
                                }
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
            if currentStep != .moodAndActivities {
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
                Text(currentStep == .journal ? "Save" : "Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedEmotion != nil ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.5))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .disabled(selectedEmotion == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Navigation

    private func goNext() {
        switch currentStep {
        case .moodAndActivities:
            currentStep = .journal
        case .journal:
            break
        }
    }

    private func goBack() {
        switch currentStep {
        case .moodAndActivities:
            break
        case .journal:
            currentStep = .moodAndActivities
        }
    }

    // MARK: - Save Entry

    private func saveEntry() {
        guard let emotion = selectedEmotion else { return }

        let entry = MoodEntry(
            mood: emotion.moodEquivalent,
            emotionId: emotion.id,
            note: journalNote.isEmpty ? nil : journalNote,
            activityTags: Array(selectedTags),
            peopleTags: Array(selectedPeople),
            earnedPoints: true
        )

        modelContext.insert(entry)

        // Update points and streak
        if let profile = userProfile {
            var points = Constants.Points.moodLog
            if !selectedTags.isEmpty {
                points += Constants.Points.contextTags
            }
            if !journalNote.isEmpty {
                points += Constants.Points.reflection
            }
            profile.totalPoints += points

            // Update streak
            streakService.updateStreak(for: profile, newEntryDate: Date())

            // Check badges (add 1 for the entry we just created)
            badgeService.checkFirstMoodBadge(profile: profile, moodEntryCount: moodEntries.count + 1)
            badgeService.checkStreakBadges(profile: profile)
        }

        dismiss()
    }
}

// MARK: - Logging Step Extension

extension MoodLoggingSheet.LoggingStep {
    var rawValue: Int {
        switch self {
        case .moodAndActivities: return 0
        case .journal: return 1
        }
    }
}

// MARK: - Emotion Button

struct EmotionButton: View {
    let emotion: EmotionOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? emotion.color.opacity(0.3) : emotion.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Text(emotion.emoji)
                        .font(.system(size: 28))
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .overlay(
                    Circle()
                        .stroke(isSelected ? emotion.color : Color.clear, lineWidth: 3)
                        .frame(width: 56, height: 56)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                )

                Text(emotion.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.moodletTextPrimary : Color.moodletTextSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - People Tag Chip

struct PeopleTagChip: View {
    let person: PeopleOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: person.icon)
                    .font(.system(size: 11))
                Text(person.name)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
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

// MARK: - Custom Activity Tag Chip

struct CustomActivityTagChip: View {
    let activity: ActivityOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: activity.icon)
                    .font(.system(size: 11))
                Text(activity.name)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
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

// MARK: - Activity Tag Chip

struct ActivityTagChip: View {
    let tag: DefaultActivityTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: tag.icon)
                    .font(.system(size: 11))
                Text(tag.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
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
