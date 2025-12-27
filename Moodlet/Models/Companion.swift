//
//  Companion.swift
//  Moodlet
//

import Foundation
import SwiftData

@Model
final class Companion {
    @Attribute(.unique) var id: UUID
    var name: String
    var species: CompanionSpecies
    var pronouns: Pronouns
    var baseColor: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify) var equippedAccessories: [Accessory]
    @Relationship(deleteRule: .nullify) var equippedBackground: Background?

    init(name: String, species: CompanionSpecies, pronouns: Pronouns, baseColor: String) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.pronouns = pronouns
        self.baseColor = baseColor
        self.createdAt = Date()
        self.equippedAccessories = []
        self.equippedBackground = nil
    }
}

enum CompanionSpecies: String, Codable, CaseIterable, Identifiable {
    case cat, bear, bunny, frog, fox, penguin

    var id: String { rawValue }

    var isPremium: Bool {
        self != .cat
    }

    var displayName: String {
        rawValue.capitalized
    }

    var description: String {
        switch self {
        case .cat: return "Cozy & independent"
        case .bear: return "Sturdy & comforting"
        case .bunny: return "Soft & gentle"
        case .frog: return "Quirky & calm"
        case .fox: return "Warm & curious"
        case .penguin: return "Resilient & cheerful"
        }
    }

    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .bear: return "🐻"
        case .bunny: return "🐰"
        case .frog: return "🐸"
        case .fox: return "🦊"
        case .penguin: return "🐧"
        }
    }
}

enum Pronouns: String, Codable, CaseIterable, Identifiable {
    case they, she, he

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .they: return "They/Them"
        case .she: return "She/Her"
        case .he: return "He/Him"
        }
    }

    var subject: String {
        switch self {
        case .they: return "they"
        case .she: return "she"
        case .he: return "he"
        }
    }

    var object: String {
        switch self {
        case .they: return "them"
        case .she: return "her"
        case .he: return "him"
        }
    }

    var possessive: String {
        switch self {
        case .they: return "their"
        case .she: return "her"
        case .he: return "his"
        }
    }
}
