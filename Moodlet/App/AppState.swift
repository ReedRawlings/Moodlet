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

    // Services
    let pointsService = PointsService()
    let streakService = StreakService()
    let notificationService = NotificationService()
    let exportService = ExportService()

    init() {
        // Load persisted state if needed
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
