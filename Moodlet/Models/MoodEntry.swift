//
//  MoodEntry.swift
//  Moodlet
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class MoodEntry {
    @Attribute(.unique) var id: UUID
    var mood: Mood
    var emotionId: String?
    var timestamp: Date
    var note: String?
    var activityTags: [String]
    var peopleTags: [String]
    var earnedPoints: Bool

    init(
        mood: Mood,
        emotionId: String? = nil,
        note: String? = nil,
        activityTags: [String] = [],
        peopleTags: [String] = [],
        earnedPoints: Bool = false
    ) {
        self.id = UUID()
        self.mood = mood
        self.emotionId = emotionId
        self.timestamp = Date()
        self.note = note
        self.activityTags = activityTags
        self.peopleTags = peopleTags
        self.earnedPoints = earnedPoints
    }

    // Get the emotion option for display (uses emotionId if available, falls back to mood)
    var emotionOption: EmotionOption? {
        if let emotionId = emotionId {
            return EmotionOption.find(byId: emotionId)
        }
        // Fallback: map Mood to default emotion
        return EmotionOption.find(byId: mood.rawValue)
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case happy
    case content
    case neutral
    case annoyed
    case sad

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var numericValue: Int {
        switch self {
        case .happy: return 5
        case .content: return 4
        case .neutral: return 3
        case .annoyed: return 2
        case .sad: return 1
        }
    }

    var color: Color {
        switch self {
        case .happy: return Color(hex: "FFD93D")
        case .content: return Color(hex: "6BCB77")
        case .neutral: return Color(hex: "B08D57")
        case .annoyed: return Color(hex: "FF8C42")
        case .sad: return Color(hex: "4D96FF")
        }
    }

    var icon: String {
        switch self {
        case .happy: return "face.smiling.fill"
        case .content: return "face.smiling"
        case .neutral: return "minus.circle"
        case .annoyed: return "exclamationmark.triangle.fill"
        case .sad: return "cloud.rain.fill"
        }
    }
}
