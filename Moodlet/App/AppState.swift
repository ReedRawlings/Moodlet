//
//  AppState.swift
//  Moodlet
//

import Foundation
import SwiftUI

@Observable
final class AppState {
    var isOnboardingComplete: Bool = false
    var selectedTab: AppTab = .home
    var showMoodLogging: Bool = false

    /// Emotion pre-selected from notification quick action (nil = show full picker)
    var pendingNotificationEmotion: EmotionOption?

    // Services
    let pointsService = PointsService()
    let streakService = StreakService()
    let notificationService = NotificationService()
    let exportService = ExportService()

    init() {
        // Load persisted state if needed
    }

    /// Called when user taps notification or selects a quick action
    @MainActor
    func handleNotificationAction(_ actionIdentifier: String) {
        // Navigate to home tab
        selectedTab = .home

        if let emotion = NotificationService.emotion(from: actionIdentifier) {
            // Quick action - pre-select the emotion
            pendingNotificationEmotion = emotion
            showMoodLogging = true
        } else {
            // Default tap or unknown action - open mood logging
            pendingNotificationEmotion = nil
            showMoodLogging = true
        }
    }
}

// MARK: - Environment Key

struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
