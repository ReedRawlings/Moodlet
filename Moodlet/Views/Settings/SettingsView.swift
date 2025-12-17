//
//  SettingsView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var companions: [Companion]

    @State private var showingExportSheet = false
    @State private var showingNotificationSettings = false
    @State private var showingCompanionCustomization = false
    @State private var showingAbout = false

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var companion: Companion? {
        companions.first
    }

    var body: some View {
        NavigationStack {
            List {
                // Companion Section
                if let companion = companion {
                    Section {
                        companionRow(companion)
                    } header: {
                        Text("Your Moodlet")
                    }
                }

                // Account Section
                Section {
                    premiumRow

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .orange,
                            title: "Notifications"
                        )
                    }
                } header: {
                    Text("Account")
                }

                // Data Section
                Section {
                    Button {
                        showingExportSheet = true
                    } label: {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: .moodletPrimary,
                            title: "Export Data"
                        )
                    }

                    NavigationLink {
                        DataManagementView()
                    } label: {
                        SettingsRow(
                            icon: "externaldrive.fill",
                            iconColor: .gray,
                            title: "Data Management"
                        )
                    }
                } header: {
                    Text("Data")
                }

                // Support Section
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "About Moodlet"
                        )
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            iconColor: .purple,
                            title: "Privacy Policy",
                            showChevron: false
                        )
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .purple,
                            title: "Terms of Service",
                            showChevron: false
                        )
                    }
                } header: {
                    Text("Support")
                }

                // App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(Color.moodletTextPrimary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
        }
    }

    // MARK: - Companion Row

    private func companionRow(_ companion: Companion) -> some View {
        NavigationLink {
            CompanionCustomizationView(companion: companion)
        } label: {
            HStack(spacing: MoodletTheme.spacing) {
                // Companion avatar placeholder
                ZStack {
                    Circle()
                        .fill(Color(hex: companion.baseColor))
                        .frame(width: 50, height: 50)

                    Text(speciesEmoji(for: companion.species))
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(companion.name)
                        .font(.headline)
                        .foregroundStyle(Color.moodletTextPrimary)

                    Text("\(companion.species.displayName) · \(companion.pronouns.displayName)")
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextSecondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func speciesEmoji(for species: CompanionSpecies) -> String {
        switch species {
        case .cat: return "🐱"
        case .bear: return "🐻"
        case .bunny: return "🐰"
        case .frog: return "🐸"
        case .fox: return "🦊"
        case .penguin: return "🐧"
        }
    }

    // MARK: - Premium Row

    private var premiumRow: some View {
        NavigationLink {
            PremiumView()
        } label: {
            HStack(spacing: MoodletTheme.spacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.moodletPrimary, .moodletAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Moodlet Premium")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.moodletTextPrimary)

                    Text(userProfile?.isPremium == true ? "Active" : "Unlock all features")
                        .font(.caption)
                        .foregroundStyle(userProfile?.isPremium == true ? Color.moodletPrimary : Color.moodletTextSecondary)
                }
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: MoodletTheme.spacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .foregroundStyle(Color.moodletTextPrimary)

            if !showChevron {
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextTertiary)
            }
        }
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var morningTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var eveningTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var showMorningReminder = true
    @State private var showEveningReminder = true

    var body: some View {
        List {
            Section {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
            } footer: {
                Text("Gentle reminders to check in with yourself")
            }

            if notificationsEnabled {
                Section {
                    Toggle("Morning Check-in", isOn: $showMorningReminder)

                    if showMorningReminder {
                        DatePicker(
                            "Time",
                            selection: $morningTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Morning")
                }

                Section {
                    Toggle("Evening Check-in", isOn: $showEveningReminder)

                    if showEveningReminder {
                        DatePicker(
                            "Time",
                            selection: $eveningTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Evening")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Management View

struct DataManagementView: View {
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Text("Your data is stored locally on your device and synced to iCloud if enabled.")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete All Data")
                    }
                }
            } footer: {
                Text("This will permanently delete all your mood entries, journal notes, and settings. This action cannot be undone.")
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Delete all data
            }
        } message: {
            Text("This will permanently delete all your data. This action cannot be undone.")
        }
    }
}

// MARK: - Export View

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .csv
    @State private var isExporting = false

    enum ExportFormat: String, CaseIterable, Identifiable {
        case csv = "CSV"
        case json = "JSON"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: MoodletTheme.largeSpacing) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.moodletPrimary)

                Text("Export Your Data")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Download all your mood entries and journal notes")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
                    .multilineTextAlignment(.center)

                Picker("Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Spacer()

                Button {
                    isExporting = true
                    // Export logic here
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isExporting = false
                        dismiss()
                    }
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Exporting..." : "Export")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.moodletPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                }
                .disabled(isExporting)
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: MoodletTheme.largeSpacing) {
                // App Icon placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.moodletPrimary, .moodletAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("🌱")
                            .font(.system(size: 50))
                    )

                VStack(spacing: 8) {
                    Text("Moodlet")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Your Mood-Reflecting Companion")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(Color.moodletTextTertiary)
                }

                VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
                    Text("About")
                        .font(.headline)

                    Text("Moodlet is a mood-tracking and journaling app featuring a stylized animal companion that reflects your emotional patterns back to you. Unlike habit-tracking apps that reward task completion, Moodlet rewards self-awareness — the act of checking in, adding context, and reflecting.")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)

                    Text("Check in with yourself. Your Moodlet reflects how you're really doing.")
                        .font(.subheadline)
                        .fontStyle(.italic)
                        .foregroundStyle(Color.moodletPrimary)
                }
                .padding()
                .background(Color.moodletSurface)
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .padding()
        }
        .background(Color.moodletBackground)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Companion Customization View

struct CompanionCustomizationView: View {
    let companion: Companion
    @State private var editedName: String = ""
    @State private var editedPronouns: Pronouns = .they

    var body: some View {
        List {
            Section {
                TextField("Name", text: $editedName)
            } header: {
                Text("Name")
            }

            Section {
                Picker("Pronouns", selection: $editedPronouns) {
                    ForEach(Pronouns.allCases) { pronoun in
                        Text(pronoun.displayName).tag(pronoun)
                    }
                }
            } header: {
                Text("Pronouns")
            }

            Section {
                HStack {
                    Text("Species")
                    Spacer()
                    Text(companion.species.displayName)
                        .foregroundStyle(Color.moodletTextSecondary)
                }

                HStack {
                    Text("Created")
                    Spacer()
                    Text(companion.createdAt.relativeDescription)
                        .foregroundStyle(Color.moodletTextSecondary)
                }
            } header: {
                Text("Info")
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = companion.name
            editedPronouns = companion.pronouns
        }
    }
}

// MARK: - Premium View

struct PremiumView: View {
    @State private var selectedPlan: PremiumPlan = .annual

    enum PremiumPlan: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case annual = "Annual"
        case lifetime = "Lifetime"

        var id: String { rawValue }

        var price: String {
            switch self {
            case .monthly: return "$4.99/mo"
            case .annual: return "$29.99/yr"
            case .lifetime: return "$79.99"
            }
        }

        var savings: String? {
            switch self {
            case .annual: return "Save 50%"
            case .lifetime: return "Best Value"
            default: return nil
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: MoodletTheme.largeSpacing) {
                // Header
                VStack(spacing: MoodletTheme.spacing) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.moodletPrimary, .moodletAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Moodlet Premium")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Unlock the full experience")
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)
                }

                // Features
                VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
                    PremiumFeatureRow(icon: "paintpalette.fill", text: "100+ exclusive accessories")
                    PremiumFeatureRow(icon: "pawprint.fill", text: "All 6 Moodlet species")
                    PremiumFeatureRow(icon: "chart.xyaxis.line", text: "Advanced insights & patterns")
                    PremiumFeatureRow(icon: "icloud.fill", text: "iCloud backup & sync")
                    PremiumFeatureRow(icon: "sparkles", text: "Seasonal exclusive items")
                }
                .padding()
                .background(Color.moodletSurface)
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))

                // Plan Selection
                VStack(spacing: MoodletTheme.smallSpacing) {
                    ForEach(PremiumPlan.allCases) { plan in
                        PremiumPlanCard(
                            plan: plan,
                            isSelected: selectedPlan == plan
                        ) {
                            selectedPlan = plan
                        }
                    }
                }

                // Subscribe Button
                Button {
                    // Purchase logic
                } label: {
                    Text("Subscribe")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moodletPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                }

                // Restore
                Button("Restore Purchases") {
                    // Restore logic
                }
                .font(.subheadline)
                .foregroundStyle(Color.moodletPrimary)

                // Legal
                Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(Color.moodletTextTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .background(Color.moodletBackground)
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: MoodletTheme.spacing) {
            Image(systemName: icon)
                .foregroundStyle(Color.moodletPrimary)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextPrimary)
        }
    }
}

struct PremiumPlanCard: View {
    let plan: PremiumView.PremiumPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.rawValue)
                            .font(.headline)
                            .foregroundStyle(Color.moodletTextPrimary)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.moodletAccent)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    Text(plan.price)
                        .font(.subheadline)
                        .foregroundStyle(Color.moodletTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.moodletPrimary : Color.moodletTextTertiary)
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius)
                    .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
