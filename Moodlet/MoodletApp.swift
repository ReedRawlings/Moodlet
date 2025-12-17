//
//  MoodletApp.swift
//  Moodlet
//

import SwiftUI
import SwiftData

@main
struct MoodletApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupInitialData()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func setupInitialData() {
        let context = sharedModelContainer.mainContext

        // Ensure user profile exists
        let profileDescriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try context.fetch(profileDescriptor)
            if profiles.isEmpty {
                let profile = UserProfile()
                context.insert(profile)
            }
        } catch {
            print("Error checking user profile: \(error)")
        }
    }
}
