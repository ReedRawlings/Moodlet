//
//  MoodletApp.swift
//  Moodlet
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct MoodletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
                .environment(\.appState, appDelegate.appState)
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

        // Sync shop catalog (adds new items, preserves existing)
        let shopSyncService = ShopSyncService()
        shopSyncService.syncCatalog(context: context)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let appState = AppState()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when user taps on notification (app was in background or closed)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier

        Task { @MainActor in
            switch actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification itself - open mood logging
                appState.handleNotificationAction(actionIdentifier)
            case UNNotificationDismissActionIdentifier:
                // User dismissed the notification - do nothing
                break
            default:
                // User selected a quick action (mood button)
                appState.handleNotificationAction(actionIdentifier)
            }
        }

        completionHandler()
    }

    /// Called when notification arrives while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
