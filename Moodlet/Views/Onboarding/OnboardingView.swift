//
//  OnboardingView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appState) private var appState
    @Query private var userProfiles: [UserProfile]

    @State private var currentStep: OnboardingStep = .companion
    @State private var selectedSpecies: CompanionSpecies = .cat
    @State private var companionName: String = ""
    @State private var selectedPronouns: Pronouns = .they
    @FocusState private var isNameFocused: Bool

    // Notification settings
    @State private var enableNotifications: Bool = true
    @State private var morningReminderEnabled: Bool = true
    @State private var eveningReminderEnabled: Bool = true
    @State private var morningTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var eveningTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()

    private enum OnboardingStep {
        case companion
        case notifications
    }

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var canContinueCompanionStep: Bool {
        !companionName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            switch currentStep {
            case .companion:
                companionStepView
            case .notifications:
                notificationStepView
            }
        }
        .background(Color.moodletBackground)
        .onTapGesture {
            isNameFocused = false
        }
    }

    // MARK: - Companion Step

    private var companionStepView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Header
                    VStack(spacing: MoodletTheme.spacing) {
                        Text("Welcome to Moodlet")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.moodletTextPrimary)

                        Text("Choose your companion to help track your moods")
                            .font(.subheadline)
                            .foregroundStyle(Color.moodletTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // Species Selection
                    VStack(spacing: MoodletTheme.spacing) {
                        Text("Pick your Moodlet")
                            .font(.headline)
                            .foregroundStyle(Color.moodletTextPrimary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: MoodletTheme.spacing) {
                            ForEach(CompanionSpecies.allCases) { species in
                                SpeciesSelectionCard(
                                    species: species,
                                    isSelected: selectedSpecies == species,
                                    isLocked: species.isPremium
                                ) {
                                    if !species.isPremium {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedSpecies = species
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Name Input
                    VStack(spacing: MoodletTheme.spacing) {
                        Text("Give them a name")
                            .font(.headline)
                            .foregroundStyle(Color.moodletTextPrimary)

                        TextField("Enter a name", text: $companionName)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.moodletSurface)
                            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius)
                                    .stroke(Color.moodletPrimary.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isNameFocused)
                    }

                    // Pronouns Selection
                    VStack(spacing: MoodletTheme.spacing) {
                        Text("Choose their pronouns")
                            .font(.headline)
                            .foregroundStyle(Color.moodletTextPrimary)

                        HStack(spacing: MoodletTheme.spacing) {
                            ForEach(Pronouns.allCases) { pronoun in
                                PronounButton(
                                    pronoun: pronoun,
                                    isSelected: selectedPronouns == pronoun
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedPronouns = pronoun
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            // Continue Button
            Button {
                createCompanionAndContinue()
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canContinueCompanionStep ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.5))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .disabled(!canContinueCompanionStep)
            .padding()
        }
    }

    // MARK: - Notification Step

    private var notificationStepView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Header
                    VStack(spacing: MoodletTheme.spacing) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.moodletPrimary)
                            .padding(.bottom, 8)

                        Text("Stay on Track")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.moodletTextPrimary)

                        Text("Get gentle reminders to check in with yourself")
                            .font(.subheadline)
                            .foregroundStyle(Color.moodletTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // Enable Notifications Toggle
                    VStack(spacing: MoodletTheme.spacing) {
                        Toggle(isOn: $enableNotifications) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Reminders")
                                    .font(.headline)
                                    .foregroundStyle(Color.moodletTextPrimary)
                                Text("We'll send friendly nudges at your preferred times")
                                    .font(.caption)
                                    .foregroundStyle(Color.moodletTextSecondary)
                            }
                        }
                        .tint(Color.moodletPrimary)
                        .padding()
                        .background(Color.moodletSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                    }

                    if enableNotifications {
                        // Morning Reminder
                        VStack(spacing: MoodletTheme.spacing) {
                            Toggle(isOn: $morningReminderEnabled) {
                                HStack {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundStyle(Color.orange)
                                    Text("Morning Check-in")
                                        .font(.headline)
                                        .foregroundStyle(Color.moodletTextPrimary)
                                }
                            }
                            .tint(Color.moodletPrimary)

                            if morningReminderEnabled {
                                DatePicker(
                                    "Time",
                                    selection: $morningTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                            }
                        }
                        .padding()
                        .background(Color.moodletSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))

                        // Evening Reminder
                        VStack(spacing: MoodletTheme.spacing) {
                            Toggle(isOn: $eveningReminderEnabled) {
                                HStack {
                                    Image(systemName: "moon.fill")
                                        .foregroundStyle(Color.indigo)
                                    Text("Evening Check-in")
                                        .font(.headline)
                                        .foregroundStyle(Color.moodletTextPrimary)
                                }
                            }
                            .tint(Color.moodletPrimary)

                            if eveningReminderEnabled {
                                DatePicker(
                                    "Time",
                                    selection: $eveningTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                            }
                        }
                        .padding()
                        .background(Color.moodletSurface)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                    }
                }
                .padding()
            }

            // Buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        await completeOnboarding()
                    }
                } label: {
                    Text(enableNotifications ? "Enable Notifications" : "Continue Without Notifications")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moodletPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                }

                if enableNotifications {
                    Button {
                        enableNotifications = false
                        Task {
                            await completeOnboarding()
                        }
                    } label: {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Actions

    private func createCompanionAndContinue() {
        let trimmedName = companionName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // Create the companion
        let companion = Companion(
            name: trimmedName,
            species: selectedSpecies,
            pronouns: selectedPronouns,
            baseColor: "2e8b57"
        )
        modelContext.insert(companion)

        // Move to notification step
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .notifications
        }
    }

    private func completeOnboarding() async {
        guard let profile = userProfile else { return }

        if enableNotifications {
            // Request permission
            let granted = await appState.notificationService.requestPermission()

            if granted {
                // Build notification times array
                var times: [Date] = []
                if morningReminderEnabled {
                    times.append(morningTime)
                }
                if eveningReminderEnabled {
                    times.append(eveningTime)
                }

                // Schedule notifications
                if !times.isEmpty {
                    try? await appState.notificationService.scheduleNotifications(times: times)
                }

                // Save to profile
                profile.notificationsEnabled = true
                profile.notificationTimes = times
            } else {
                // Permission denied
                profile.notificationsEnabled = false
                profile.notificationTimes = []
            }
        } else {
            profile.notificationsEnabled = false
            profile.notificationTimes = []
        }

        // Mark onboarding as completed
        profile.onboardingCompleted = true
    }
}

// MARK: - Species Selection Card

struct SpeciesSelectionCard: View {
    let species: CompanionSpecies
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.moodletPrimary.opacity(0.2) : Color.moodletSurface)
                        .frame(width: 70, height: 70)

                    CompanionImage(species: species, expression: "neutral", size: 60)

                    if isLocked {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 70, height: 70)

                        Image(systemName: "lock.fill")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 3)
                        .frame(width: 70, height: 70)
                )

                Text(species.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isLocked ? Color.moodletTextTertiary : Color.moodletTextPrimary)

                if isLocked {
                    Text("Premium")
                        .font(.caption2)
                        .foregroundStyle(Color.moodletAccent)
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.7 : 1.0)
    }
}

// MARK: - Pronoun Button

struct PronounButton: View {
    let pronoun: Pronouns
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(pronoun.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
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

#Preview {
    OnboardingView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
