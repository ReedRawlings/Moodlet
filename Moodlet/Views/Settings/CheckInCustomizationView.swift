//
//  CheckInCustomizationView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct CheckInCustomizationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var selectedTab: CustomizationTab = .emotions

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    enum CustomizationTab: String, CaseIterable, Identifiable {
        case emotions = "Emotions"
        case activities = "Activities"
        case people = "People"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("Category", selection: $selectedTab) {
                ForEach(CustomizationTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Content
            ScrollView {
                switch selectedTab {
                case .emotions:
                    EmotionSelectionView(userProfile: userProfile)
                case .activities:
                    ActivityCustomizationView(userProfile: userProfile)
                case .people:
                    PeopleCustomizationView(userProfile: userProfile)
                }
            }
        }
        .background(Color.moodletBackground)
        .navigationTitle("Customize Check-in")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Emotion Selection View

struct EmotionSelectionView: View {
    let userProfile: UserProfile?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Select which emotions to show during check-in")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: MoodletTheme.spacing) {
                ForEach(EmotionOption.presets) { emotion in
                    EmotionToggleCard(
                        emotion: emotion,
                        isSelected: userProfile?.selectedEmotionIds.contains(emotion.id) ?? false
                    ) {
                        toggleEmotion(emotion)
                    }
                }
            }
            .padding()
        }
    }

    private func toggleEmotion(_ emotion: EmotionOption) {
        guard let profile = userProfile else { return }

        if profile.selectedEmotionIds.contains(emotion.id) {
            // Don't allow removing if only one left
            if profile.selectedEmotionIds.count > 1 {
                profile.selectedEmotionIds.removeAll { $0 == emotion.id }
            }
        } else {
            profile.selectedEmotionIds.append(emotion.id)
        }
    }
}

struct EmotionToggleCard: View {
    let emotion: EmotionOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? emotion.color.opacity(0.3) : Color.moodletBackground)
                        .frame(width: 60, height: 60)

                    Text(emotion.emoji)
                        .font(.system(size: 32))

                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.moodletPrimary)
                            }
                            Spacer()
                        }
                        .frame(width: 60, height: 60)
                    }
                }

                Text(emotion.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.moodletTextPrimary : Color.moodletTextSecondary)
            }
            .padding(8)
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                    .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Customization View

struct ActivityCustomizationView: View {
    let userProfile: UserProfile?
    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Choose which activities to show during check-in")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)
                .padding(.horizontal)

            VStack(spacing: MoodletTheme.smallSpacing) {
                // Preset activities
                ForEach(ActivityOption.presets) { activity in
                    ActivityToggleRow(
                        name: activity.name,
                        icon: activity.icon,
                        isSelected: userProfile?.selectedActivityIds.contains(activity.id) ?? false
                    ) {
                        toggleActivity(activity.id)
                    }
                }

                // Custom activities
                if let customActivities = userProfile?.customActivities, !customActivities.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    Text("Custom Activities")
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextTertiary)
                        .padding(.horizontal)

                    ForEach(customActivities) { activity in
                        ActivityToggleRow(
                            name: activity.name,
                            icon: activity.icon,
                            isSelected: userProfile?.selectedActivityIds.contains(activity.id) ?? false,
                            isCustom: true,
                            onDelete: { deleteCustomActivity(activity) }
                        ) {
                            toggleActivity(activity.id)
                        }
                    }
                }

                // Add button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.moodletPrimary)
                        Text("Add Custom Activity")
                            .foregroundStyle(Color.moodletPrimary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.moodletSurface)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCustomItemSheet(
                itemType: "Activity",
                icons: SFSymbolPicker.activityIcons
            ) { name, icon in
                addCustomActivity(name: name, icon: icon)
            }
        }
    }

    private func toggleActivity(_ id: String) {
        guard let profile = userProfile else { return }

        if profile.selectedActivityIds.contains(id) {
            profile.selectedActivityIds.removeAll { $0 == id }
        } else {
            profile.selectedActivityIds.append(id)
        }
    }

    private func addCustomActivity(name: String, icon: String) {
        guard let profile = userProfile else { return }

        let newActivity = ActivityOption(name: name, icon: icon, isCustom: true)
        var activities = profile.customActivities
        activities.append(newActivity)
        profile.customActivities = activities
        profile.selectedActivityIds.append(newActivity.id)
    }

    private func deleteCustomActivity(_ activity: ActivityOption) {
        guard let profile = userProfile else { return }

        var activities = profile.customActivities
        activities.removeAll { $0.id == activity.id }
        profile.customActivities = activities
        profile.selectedActivityIds.removeAll { $0 == activity.id }
    }
}

// MARK: - People Customization View

struct PeopleCustomizationView: View {
    let userProfile: UserProfile?
    @State private var showingAddSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Choose which options to show for \"Who are you with?\"")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)
                .padding(.horizontal)

            VStack(spacing: MoodletTheme.smallSpacing) {
                // Preset options
                ForEach(PeopleOption.presets) { option in
                    ActivityToggleRow(
                        name: option.name,
                        icon: option.icon,
                        isSelected: userProfile?.selectedPeopleIds.contains(option.id) ?? false
                    ) {
                        togglePeople(option.id)
                    }
                }

                // Custom options
                if let customPeople = userProfile?.customPeople, !customPeople.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    Text("Custom Options")
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextTertiary)
                        .padding(.horizontal)

                    ForEach(customPeople) { option in
                        ActivityToggleRow(
                            name: option.name,
                            icon: option.icon,
                            isSelected: userProfile?.selectedPeopleIds.contains(option.id) ?? false,
                            isCustom: true,
                            onDelete: { deleteCustomPeople(option) }
                        ) {
                            togglePeople(option.id)
                        }
                    }
                }

                // Add button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.moodletPrimary)
                        Text("Add Custom Option")
                            .foregroundStyle(Color.moodletPrimary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.moodletSurface)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCustomItemSheet(
                itemType: "Option",
                icons: SFSymbolPicker.peopleIcons
            ) { name, icon in
                addCustomPeople(name: name, icon: icon)
            }
        }
    }

    private func togglePeople(_ id: String) {
        guard let profile = userProfile else { return }

        if profile.selectedPeopleIds.contains(id) {
            profile.selectedPeopleIds.removeAll { $0 == id }
        } else {
            profile.selectedPeopleIds.append(id)
        }
    }

    private func addCustomPeople(name: String, icon: String) {
        guard let profile = userProfile else { return }

        let newOption = PeopleOption(name: name, icon: icon, isCustom: true)
        var options = profile.customPeople
        options.append(newOption)
        profile.customPeople = options
        profile.selectedPeopleIds.append(newOption.id)
    }

    private func deleteCustomPeople(_ option: PeopleOption) {
        guard let profile = userProfile else { return }

        var options = profile.customPeople
        options.removeAll { $0.id == option.id }
        profile.customPeople = options
        profile.selectedPeopleIds.removeAll { $0 == option.id }
    }
}

// MARK: - Activity Toggle Row

struct ActivityToggleRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    var isCustom: Bool = false
    var onDelete: (() -> Void)?
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                HStack(spacing: MoodletTheme.spacing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.moodletPrimary.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.moodletPrimary)
                    }

                    Text(name)
                        .foregroundStyle(Color.moodletTextPrimary)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.moodletPrimary : Color.moodletTextTertiary)
                }
            }
            .buttonStyle(.plain)

            if isCustom, let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(Color.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
    }
}

// MARK: - Add Custom Item Sheet

struct AddCustomItemSheet: View {
    let itemType: String
    let icons: [String]
    let onAdd: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedIcon = "star.fill"

    private let iconColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: MoodletTheme.largeSpacing) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)

                    TextField("Enter name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                // Icon picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)

                    ScrollView {
                        LazyVGrid(columns: iconColumns, spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIcon == icon ? Color.moodletPrimary.opacity(0.2) : Color.moodletBackground)
                                            .frame(width: 44, height: 44)

                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundStyle(selectedIcon == icon ? Color.moodletPrimary : Color.moodletTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }

                Spacer()

                // Add button
                Button {
                    if !name.isEmpty {
                        onAdd(name, selectedIcon)
                        dismiss()
                    }
                } label: {
                    Text("Add \(itemType)")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.moodletPrimary.opacity(0.5) : Color.moodletPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                }
                .disabled(name.isEmpty)
            }
            .padding()
            .navigationTitle("Add Custom \(itemType)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        CheckInCustomizationView()
    }
    .modelContainer(for: [
        UserProfile.self
    ], inMemory: true)
}
