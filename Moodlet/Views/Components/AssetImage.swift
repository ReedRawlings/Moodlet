//
//  AssetImage.swift
//  Moodlet
//

import SwiftUI

/// A view that attempts to load an image from assets, falling back to a placeholder if not found.
/// This allows gradual addition of real assets while maintaining placeholder functionality.
struct AssetImage: View {
    let name: String
    let placeholder: String
    var contentMode: ContentMode = .fit

    var body: some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Image(systemName: placeholder)
                .font(.title)
                .foregroundStyle(Color.moodletTextTertiary)
        }
    }
}

/// Helper for companion images
struct CompanionImage: View {
    let species: CompanionSpecies
    let expression: String
    var size: CGFloat = 120

    /// Asset name follows pattern: "Companions/{Species}/{species}_{expression}"
    /// e.g., "Companions/Cat/cat_happy"
    private var assetName: String {
        "Companions/\(species.displayName)/\(species.rawValue)_\(expression)"
    }

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            // Fallback to placeholder
            CompanionPlaceholderCircle(species: species, expression: expression, size: size)
        }
    }
}

/// Simple placeholder circle for companions when no asset exists
struct CompanionPlaceholderCircle: View {
    let species: CompanionSpecies
    let expression: String
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.moodletPrimary.opacity(0.3))
                .frame(width: size, height: size)

            Text(speciesEmoji)
                .font(.system(size: size * 0.5))
        }
    }

    private var speciesEmoji: String {
        switch species {
        case .cat: return "🐱"
        case .bear: return "🐻"
        case .bunny: return "🐰"
        case .frog: return "🐸"
        case .fox: return "🦊"
        case .penguin: return "🐧"
        }
    }
}

/// Helper for accessory images
struct AccessoryImage: View {
    let accessory: Accessory
    var size: CGFloat = 60

    /// Asset name follows pattern: "Accessories/{Category}/{imageName}"
    /// e.g., "Accessories/Hats/cozy_beanie"
    private var assetName: String {
        "Accessories/\(accessory.category.folderName)/\(accessory.imageName)"
    }

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            // Fallback to category icon
            Image(systemName: accessory.category.icon)
                .font(.title)
                .foregroundStyle(Color.moodletTextTertiary)
        }
    }
}

/// Helper for background images
struct BackgroundImage: View {
    let background: Background
    var contentMode: ContentMode = .fill

    /// Asset name follows pattern: "Backgrounds/{imageName}"
    /// e.g., "Backgrounds/cozy_room"
    private var assetName: String {
        "Backgrounds/\(background.imageName)"
    }

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            // Fallback gradient
            LinearGradient(
                colors: [
                    Color.moodletPrimary.opacity(0.1),
                    Color.moodletAccent.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Extensions for folder names

extension AccessoryCategory {
    var folderName: String {
        switch self {
        case .hat: return "Hats"
        case .glasses: return "Glasses"
        case .scarf: return "Scarves"
        case .heldItem: return "HeldItems"
        case .outfit: return "Outfits"
        }
    }
}
