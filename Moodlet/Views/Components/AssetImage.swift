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

/// Helper for companion base images (single image per species, accessories layered separately)
struct CompanionImage: View {
    let species: CompanionSpecies
    var size: CGFloat = 120

    /// Asset name follows pattern: "Companions/{species}"
    /// e.g., "Companions/cat"
    private var assetName: String {
        "Companions/\(species.rawValue)"
    }

    var body: some View {
        if let uiImage = UIImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            // Fallback to placeholder
            CompanionPlaceholderCircle(species: species, size: size)
        }
    }
}

/// Simple placeholder circle for companions when no asset exists
struct CompanionPlaceholderCircle: View {
    let species: CompanionSpecies
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.moodletPrimary.opacity(0.3))
                .frame(width: size, height: size)

            Text(species.emoji)
                .font(.system(size: size * 0.5))
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
        case .eyes: return "Eyes"
        case .glasses: return "Glasses"
        case .hat: return "Hats"
        case .top: return "Tops"
        case .heldItem: return "HeldItems"
        }
    }
}
