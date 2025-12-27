//
//  CompanionView.swift
//  Moodlet
//

import SwiftUI

struct CompanionView: View {
    let companion: Companion?
    let moodTrend: Mood?
    var points: Int = 0
    var streak: Int = 0
    var entries: Int = 0

    @State private var isAnimating = false


    var body: some View {
        ZStack(alignment: .top) {
            // Background
            backgroundView

            // Companion
            companionDisplay

            // Stats overlay row
            statsOverlay
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.largeCornerRadius))
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        Group {
            if let background = companion?.equippedBackground {
                BackgroundImage(background: background)
            } else {
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

    // MARK: - Stats Overlay

    private var statsOverlay: some View {
        HStack(spacing: 12) {
            // Streak
            statBadge(icon: "flame.fill", value: "\(streak)", color: .orange)

            // Entries
            statBadge(icon: "checkmark.circle.fill", value: "\(entries)", color: .moodletPrimary)

            Spacer()

            // Points
            statBadge(icon: "star.fill", value: "\(points)", color: .moodletAccent)
        }
    }

    private func statBadge(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.moodletSurface.opacity(0.9))
        .clipShape(Capsule())
    }

    // MARK: - Companion Display

    @ViewBuilder
    private var companionDisplay: some View {
        if let companion = companion {
            VStack {
                Spacer()

                // Companion with layered accessories
                ZStack {
                    // Base companion image
                    CompanionImage(species: companion.species, size: 180)

                    // Equipped accessories layered in order
                    ForEach(companion.equippedAccessories.sorted { $0.category.layerOrder < $1.category.layerOrder }) { accessory in
                        AccessoryImage(accessory: accessory, size: 180)
                    }
                }
                .scaleEffect(isAnimating ? 1.02 : 1.0)
                .offset(y: isAnimating ? -4 : 0)

                Spacer()
            }
        } else {
            // No companion state
            VStack(spacing: MoodletTheme.spacing) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.moodletTextTertiary)

                Text("Complete onboarding to meet your Moodlet!")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

// MARK: - Companion Placeholder

struct CompanionPlaceholder: View {
    let species: CompanionSpecies
    let expression: String
    let baseColor: Color

    var body: some View {
        VStack(spacing: 8) {
            // Simple placeholder representation
            ZStack {
                // Body
                Circle()
                    .fill(baseColor)
                    .frame(width: 120, height: 120)

                // Face based on species
                speciesFace
            }

            // Species label
            Text(species.displayName)
                .font(.caption)
                .foregroundStyle(Color.moodletTextSecondary)
        }
    }

    @ViewBuilder
    private var speciesFace: some View {
        VStack(spacing: 8) {
            // Eyes
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.moodletDark)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(Color.moodletDark)
                    .frame(width: 12, height: 12)
            }

            // Expression
            expressionMouth
        }
    }

    @ViewBuilder
    private var expressionMouth: some View {
        switch expression {
        case "happy":
            // Big smile
            Image(systemName: "face.smiling")
                .font(.title)
                .foregroundStyle(Color.moodletDark)
        case "content":
            // Small smile
            Capsule()
                .fill(Color.moodletDark)
                .frame(width: 20, height: 6)
        case "sad":
            // Frown
            Capsule()
                .fill(Color.moodletDark)
                .frame(width: 16, height: 4)
                .rotationEffect(.degrees(180))
        case "tired":
            // Neutral line
            Rectangle()
                .fill(Color.moodletDark)
                .frame(width: 16, height: 3)
        default:
            // Neutral
            Circle()
                .fill(Color.moodletDark)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview {
    VStack {
        CompanionView(
            companion: nil,
            moodTrend: nil
        )
        .frame(height: 280)
        .padding()
    }
    .background(Color.moodletBackground)
}
