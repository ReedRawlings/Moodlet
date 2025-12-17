//
//  ContentView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    private var hasCompletedOnboarding: Bool {
        userProfiles.first?.onboardingCompleted ?? false
    }

    var body: some View {
        // For now, always show the main app
        // Onboarding will be implemented separately
        MainTabView()
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
