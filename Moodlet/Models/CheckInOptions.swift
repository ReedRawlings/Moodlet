//
//  CheckInOptions.swift
//  Moodlet
//

import Foundation
import SwiftUI

// MARK: - Emotion Option

struct EmotionOption: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let colorHex: String

    var color: Color {
        Color(hex: colorHex)
    }

    // Map to Mood enum for numeric tracking
    var moodEquivalent: Mood {
        switch id {
        case "happy", "excited", "grateful": return .happy
        case "content", "calm": return .content
        case "neutral", "tired": return .neutral
        case "annoyed", "frustrated", "stressed": return .annoyed
        case "sad", "anxious": return .sad
        default: return .neutral
        }
    }

    static let presets: [EmotionOption] = [
        EmotionOption(id: "happy", name: "Happy", emoji: "😊", colorHex: "FFD93D"),
        EmotionOption(id: "content", name: "Content", emoji: "😌", colorHex: "6BCB77"),
        EmotionOption(id: "neutral", name: "Neutral", emoji: "😐", colorHex: "B08D57"),
        EmotionOption(id: "annoyed", name: "Annoyed", emoji: "😤", colorHex: "FF8C42"),
        EmotionOption(id: "sad", name: "Sad", emoji: "😢", colorHex: "4D96FF"),
        EmotionOption(id: "anxious", name: "Anxious", emoji: "😰", colorHex: "9B59B6"),
        EmotionOption(id: "excited", name: "Excited", emoji: "🤩", colorHex: "FF6B6B"),
        EmotionOption(id: "tired", name: "Tired", emoji: "😴", colorHex: "778899"),
        EmotionOption(id: "grateful", name: "Grateful", emoji: "🙏", colorHex: "20B2AA"),
        EmotionOption(id: "frustrated", name: "Frustrated", emoji: "😠", colorHex: "DC143C"),
        EmotionOption(id: "calm", name: "Calm", emoji: "😇", colorHex: "87CEEB"),
        EmotionOption(id: "stressed", name: "Stressed", emoji: "😫", colorHex: "FF4500"),
    ]

    static let defaultSelection = ["happy", "content", "neutral", "annoyed", "sad"]

    static func find(byId id: String) -> EmotionOption? {
        presets.first { $0.id == id }
    }
}

// MARK: - Activity Option

struct ActivityOption: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let isCustom: Bool

    init(id: String? = nil, name: String, icon: String, isCustom: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.icon = icon
        self.isCustom = isCustom
    }

    static let presets: [ActivityOption] = [
        ActivityOption(id: "sleep", name: "Sleep", icon: "moon.fill"),
        ActivityOption(id: "work", name: "Work", icon: "briefcase.fill"),
        ActivityOption(id: "exercise", name: "Exercise", icon: "figure.run"),
        ActivityOption(id: "social", name: "Social", icon: "person.2.fill"),
        ActivityOption(id: "family", name: "Family", icon: "house.fill"),
        ActivityOption(id: "outdoors", name: "Outdoors", icon: "leaf.fill"),
        ActivityOption(id: "relaxing", name: "Relaxing", icon: "cup.and.saucer.fill"),
        ActivityOption(id: "creative", name: "Creative", icon: "paintbrush.fill"),
        ActivityOption(id: "health", name: "Health", icon: "heart.fill"),
        ActivityOption(id: "food", name: "Food", icon: "fork.knife"),
        ActivityOption(id: "weather_good", name: "Good Weather", icon: "sun.max.fill"),
        ActivityOption(id: "weather_bad", name: "Bad Weather", icon: "cloud.rain.fill"),
    ]

    static let defaultSelection: [String] = presets.map { $0.id }

    static func find(byId id: String) -> ActivityOption? {
        presets.first { $0.id == id }
    }
}

// MARK: - People Option

struct PeopleOption: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let isCustom: Bool

    init(id: String? = nil, name: String, icon: String, isCustom: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.icon = icon
        self.isCustom = isCustom
    }

    static let presets: [PeopleOption] = [
        PeopleOption(id: "alone", name: "Alone", icon: "person.fill"),
        PeopleOption(id: "family", name: "Family", icon: "house.fill"),
        PeopleOption(id: "friends", name: "Friends", icon: "person.2.fill"),
        PeopleOption(id: "work", name: "Work", icon: "briefcase.fill"),
    ]

    static let defaultSelection: [String] = presets.map { $0.id }

    static func find(byId id: String) -> PeopleOption? {
        presets.first { $0.id == id }
    }
}

// MARK: - Common SF Symbols for Custom Items

struct SFSymbolPicker {
    static let activityIcons: [String] = [
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "flame.fill",
        "leaf.fill",
        "drop.fill",
        "snowflake",
        "moon.fill",
        "sun.max.fill",
        "cloud.fill",
        "wind",
        "figure.walk",
        "figure.run",
        "bicycle",
        "car.fill",
        "airplane",
        "house.fill",
        "building.2.fill",
        "book.fill",
        "music.note",
        "gamecontroller.fill",
        "tv.fill",
        "phone.fill",
        "laptopcomputer",
        "cart.fill",
        "bag.fill",
        "gift.fill",
        "camera.fill",
        "paintbrush.fill",
        "pencil",
        "scissors",
        "hammer.fill",
        "wrench.fill",
        "stethoscope",
        "pills.fill",
        "cross.fill",
        "bed.double.fill",
        "fork.knife",
        "cup.and.saucer.fill",
        "wineglass.fill",
    ]

    static let peopleIcons: [String] = [
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "figure.stand",
        "figure.wave",
        "house.fill",
        "building.fill",
        "briefcase.fill",
        "graduationcap.fill",
        "heart.fill",
        "star.fill",
    ]
}
