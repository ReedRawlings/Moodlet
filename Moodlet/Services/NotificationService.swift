//
//  NotificationService.swift
//  Moodlet
//

import Foundation
import UserNotifications

// MARK: - Notification Constants

enum NotificationAction {
    static let categoryIdentifier = "MOOD_CHECKIN"
    static let emotionActionPrefix = "EMOTION_"

    /// Create action identifier for an emotion
    static func actionIdentifier(for emotionId: String) -> String {
        "\(emotionActionPrefix)\(emotionId.uppercased())"
    }

    /// Extract emotion ID from action identifier
    static func emotionId(from actionIdentifier: String) -> String? {
        guard actionIdentifier.hasPrefix(emotionActionPrefix) else { return nil }
        return String(actionIdentifier.dropFirst(emotionActionPrefix.count)).lowercased()
    }
}

@Observable
final class NotificationService {
    var hasPermission: Bool = false

    init() {
        Task {
            await checkPermission()
            // Register with default emotions initially
            await registerNotificationCategories(emotionIds: EmotionOption.defaultSelection)
        }
    }

    @MainActor
    func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        hasPermission = settings.authorizationStatus == .authorized
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                hasPermission = granted
            }
            return granted
        } catch {
            return false
        }
    }

    /// Register notification categories with the user's selected emotion options
    func registerNotificationCategories(emotionIds: [String]) async {
        let center = UNUserNotificationCenter.current()

        // Get emotion options for the selected IDs (limit to 4 for iOS notification actions)
        let emotions = emotionIds.compactMap { EmotionOption.find(byId: $0) }.prefix(4)

        // Create actions from user's selected emotions
        let actions = emotions.map { emotion in
            UNNotificationAction(
                identifier: NotificationAction.actionIdentifier(for: emotion.id),
                title: "\(emotion.emoji) \(emotion.name)",
                options: []
            )
        }

        // Create category with user's emotion actions
        let moodCategory = UNNotificationCategory(
            identifier: NotificationAction.categoryIdentifier,
            actions: Array(actions),
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([moodCategory])
    }

    /// Schedule notifications and update categories with user's emotion preferences
    func scheduleNotifications(times: [Date], emotionIds: [String]? = nil) async throws {
        let center = UNUserNotificationCenter.current()

        // Update notification categories if emotion IDs provided
        if let emotionIds = emotionIds {
            await registerNotificationCategories(emotionIds: emotionIds)
        }

        // Clear existing notifications
        center.removeAllPendingNotificationRequests()

        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Moodlet"

            let hour = Calendar.current.component(.hour, from: time)
            content.body = NotificationMessages.message(for: hour)
            content.sound = .default
            content.categoryIdentifier = NotificationAction.categoryIdentifier

            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let request = UNNotificationRequest(
                identifier: "moodlet_checkin_\(index)",
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    /// Get EmotionOption from notification action identifier
    static func emotion(from actionIdentifier: String) -> EmotionOption? {
        guard let emotionId = NotificationAction.emotionId(from: actionIdentifier) else {
            return nil
        }
        return EmotionOption.find(byId: emotionId)
    }
}
