//
//  DependencyContainer.swift
//  Moodlet
//

import Foundation
import SwiftData

/// A container for app-wide dependencies and services
final class DependencyContainer {
    static let shared = DependencyContainer()

    // Services
    let dataService = DataService()
    let pointsService = PointsService()
    let streakService = StreakService()
    let notificationService = NotificationService()
    let exportService = ExportService()

    private init() {}

    func configure(with modelContext: ModelContext) {
        dataService.configure(with: modelContext)
    }
}
