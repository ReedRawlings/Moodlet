//
//  NotificationService.swift
//  Moodlet
//

import Foundation
import UserNotifications

@Observable
final class NotificationService {
    var hasPermission: Bool = false

    init() {
        Task {
            await checkPermission()
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

    func scheduleNotifications(times: [Date]) async throws {
        let center = UNUserNotificationCenter.current()

        // Clear existing notifications
        center.removeAllPendingNotificationRequests()

        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Moodlet"

            let hour = Calendar.current.component(.hour, from: time)
            content.body = NotificationMessages.message(for: hour)
            content.sound = .default

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
}
