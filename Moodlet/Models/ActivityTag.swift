//
//  ActivityTag.swift
//  Moodlet
//

import Foundation

enum DefaultActivityTag: String, CaseIterable, Identifiable {
    case sleep = "Sleep"
    case work = "Work"
    case exercise = "Exercise"
    case social = "Social"
    case family = "Family"
    case outdoors = "Outdoors"
    case relaxing = "Relaxing"
    case creative = "Creative"
    case health = "Health"
    case food = "Food"
    case weatherGood = "Good Weather"
    case weatherBad = "Bad Weather"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sleep: return "moon.fill"
        case .work: return "briefcase.fill"
        case .exercise: return "figure.run"
        case .social: return "person.2.fill"
        case .family: return "house.fill"
        case .outdoors: return "leaf.fill"
        case .relaxing: return "cup.and.saucer.fill"
        case .creative: return "paintbrush.fill"
        case .health: return "heart.fill"
        case .food: return "fork.knife"
        case .weatherGood: return "sun.max.fill"
        case .weatherBad: return "cloud.rain.fill"
        }
    }
}
