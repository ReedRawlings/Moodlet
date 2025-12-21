//
//  Badge.swift
//  Moodlet
//

import SwiftUI

enum Badge: String, CaseIterable, Identifiable {
    case firstMood
    case streak3Day
    case streak5Day
    case firstPurchase
    case dressUp

    var id: String { rawValue }

    var name: String {
        switch self {
        case .firstMood: return "First Check-In"
        case .streak3Day: return "3-Day Streak"
        case .streak5Day: return "5-Day Streak"
        case .firstPurchase: return "First Purchase"
        case .dressUp: return "Dress Up"
        }
    }

    var description: String {
        switch self {
        case .firstMood: return "Log your first mood"
        case .streak3Day: return "Maintain a 3-day streak"
        case .streak5Day: return "Maintain a 5-day streak"
        case .firstPurchase: return "Buy your first item from the shop"
        case .dressUp: return "Equip an accessory to your Moodlet"
        }
    }

    var icon: String {
        switch self {
        case .firstMood: return "heart.fill"
        case .streak3Day: return "flame.fill"
        case .streak5Day: return "flame.fill"
        case .firstPurchase: return "bag.fill"
        case .dressUp: return "tshirt.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstMood: return Color(hex: "FF6B6B")
        case .streak3Day: return Color(hex: "FF9F43")
        case .streak5Day: return Color(hex: "EE5A24")
        case .firstPurchase: return Color(hex: "6BCB77")
        case .dressUp: return Color(hex: "9B59B6")
        }
    }
}
