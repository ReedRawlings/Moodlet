//
//  MoodletError.swift
//  Moodlet
//

import Foundation

enum MoodletError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case exportFailed
    case purchaseFailed
    case notificationPermissionDenied
    case cloudSyncFailed
    case invalidInput(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "Unable to load your data"
        case .dataSaveFailed:
            return "Unable to save your entry"
        case .exportFailed:
            return "Export failed"
        case .purchaseFailed:
            return "Purchase could not be completed"
        case .notificationPermissionDenied:
            return "Notification permission needed"
        case .cloudSyncFailed:
            return "Unable to sync with iCloud"
        case .invalidInput(let message):
            return message
        case .unknown:
            return "An unexpected error occurred"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dataLoadFailed:
            return "Try restarting the app"
        case .dataSaveFailed:
            return "Please try again"
        case .exportFailed:
            return "Check your storage space and try again"
        case .purchaseFailed:
            return "Check your payment method and try again"
        case .notificationPermissionDenied:
            return "Enable notifications in Settings"
        case .cloudSyncFailed:
            return "Check your internet connection"
        case .invalidInput:
            return "Please check your input and try again"
        case .unknown:
            return "Please try again"
        }
    }
}
