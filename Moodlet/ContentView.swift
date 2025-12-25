//
//  ContentView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var companions: [Companion]

    private var hasCompletedOnboarding: Bool {
        userProfiles.first?.onboardingCompleted ?? false
    }

    private var hasCompanion: Bool {
        !companions.isEmpty
    }

    var body: some View {
        if hasCompletedOnboarding && hasCompanion {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
