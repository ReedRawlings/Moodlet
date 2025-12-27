//
//  WardrobeView.swift
//  Moodlet
//
//  Allows users to equip/unequip accessories on their companion
//

import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    @Query private var accessories: [Accessory]
    @Query private var backgrounds: [Background]
    @Query private var companions: [Companion]

    @State private var selectedCategory: WardrobeCategory = .glasses

    private var userProfile: UserProfile? { userProfiles.first }
    private var companion: Companion? { companions.first }

    enum WardrobeCategory: String, CaseIterable, Identifiable {
        case glasses, hats, tops, eyes, heldItems, backgrounds

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .glasses: return "Glasses"
            case .hats: return "Hats"
            case .tops: return "Tops"
            case .eyes: return "Eyes"
            case .heldItems: return "Items"
            case .backgrounds: return "Backgrounds"
            }
        }

        var icon: String {
            switch self {
            case .glasses: return "eyeglasses"
            case .hats: return "crown.fill"
            case .tops: return "tshirt.fill"
            case .eyes: return "eye.fill"
            case .heldItems: return "hand.raised.fill"
            case .backgrounds: return "photo.fill"
            }
        }

        var accessoryCategory: AccessoryCategory? {
            switch self {
            case .glasses: return .glasses
            case .hats: return .hat
            case .tops: return .top
            case .eyes: return .eyes
            case .heldItems: return .heldItem
            case .backgrounds: return nil
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Companion preview
                companionPreview
                    .frame(height: 200)

                // Category tabs
                categoryPicker

                // Items grid
                ScrollView {
                    itemsGrid
                        .padding()
                }
            }
            .background(Color.moodletBackground)
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Companion Preview

    private var companionPreview: some View {
        ZStack {
            // Background
            if let bg = companion?.equippedBackground {
                BackgroundImage(background: bg)
            } else {
                LinearGradient(
                    colors: [Color.moodletPrimary.opacity(0.3), Color.moodletPrimary.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            // Companion with accessories
            if let companion = companion {
                ZStack {
                    CompanionImage(species: companion.species, size: 140)

                    ForEach(companion.equippedAccessories.sorted { $0.category.layerOrder < $1.category.layerOrder }) { accessory in
                        AccessoryImage(accessory: accessory, size: 140)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        .padding()
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WardrobeCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 18))
                            Text(category.displayName)
                                .font(.caption2)
                        }
                        .frame(width: 60, height: 50)
                        .background(selectedCategory == category ? Color.moodletPrimary : Color.moodletSurface)
                        .foregroundStyle(selectedCategory == category ? .white : Color.moodletTextPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.moodletSurface.opacity(0.5))
    }

    // MARK: - Items Grid

    private var itemsGrid: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            if selectedCategory == .backgrounds {
                backgroundItems
            } else {
                accessoryItems
            }
        }
    }

    @ViewBuilder
    private var accessoryItems: some View {
        if let category = selectedCategory.accessoryCategory {
            let unlockedItems = accessories.filter { accessory in
                accessory.category == category &&
                (userProfile?.unlockedAccessoryIDs.contains(accessory.id) ?? false)
            }

            if unlockedItems.isEmpty {
                emptyStateView
            } else {
                // "None" option to unequip
                NoneItemCard(
                    isSelected: !isAnyCategoryEquipped(category),
                    action: { unequipCategory(category) }
                )

                ForEach(unlockedItems) { accessory in
                    WardrobeAccessoryCard(
                        accessory: accessory,
                        isEquipped: isEquipped(accessory),
                        action: { toggleAccessory(accessory) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var backgroundItems: some View {
        let unlockedBgs = backgrounds.filter { bg in
            userProfile?.unlockedBackgroundIDs.contains(bg.id) ?? false
        }

        if unlockedBgs.isEmpty {
            emptyStateView
        } else {
            // "None" option
            NoneItemCard(
                isSelected: companion?.equippedBackground == nil,
                action: { unequipBackground() }
            )

            ForEach(unlockedBgs) { background in
                WardrobeBackgroundCard(
                    background: background,
                    isEquipped: companion?.equippedBackground?.id == background.id,
                    action: { equipBackground(background) }
                )
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag")
                .font(.largeTitle)
                .foregroundStyle(Color.moodletTextTertiary)
            Text("No items yet")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)
            Text("Visit the shop to unlock items!")
                .font(.caption)
                .foregroundStyle(Color.moodletTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .gridCellColumns(3)
    }

    // MARK: - Actions

    private func isEquipped(_ accessory: Accessory) -> Bool {
        companion?.equippedAccessories.contains { $0.id == accessory.id } ?? false
    }

    private func isAnyCategoryEquipped(_ category: AccessoryCategory) -> Bool {
        companion?.equippedAccessories.contains { $0.category == category } ?? false
    }

    private func toggleAccessory(_ accessory: Accessory) {
        guard let companion = companion else { return }

        if isEquipped(accessory) {
            // Unequip
            companion.equippedAccessories.removeAll { $0.id == accessory.id }
        } else {
            // Unequip any existing item in same category, then equip new one
            companion.equippedAccessories.removeAll { $0.category == accessory.category }
            companion.equippedAccessories.append(accessory)
        }
    }

    private func unequipCategory(_ category: AccessoryCategory) {
        companion?.equippedAccessories.removeAll { $0.category == category }
    }

    private func equipBackground(_ background: Background) {
        companion?.equippedBackground = background
    }

    private func unequipBackground() {
        companion?.equippedBackground = nil
    }
}

// MARK: - Item Cards

struct NoneItemCard: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.moodletSurface)
                        .frame(width: 60, height: 60)

                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(Color.moodletTextSecondary)
                }

                Text("None")
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.moodletPrimary.opacity(0.15) : Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct WardrobeAccessoryCard: View {
    let accessory: Accessory
    let isEquipped: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                AccessoryImage(accessory: accessory, size: 60)
                    .frame(width: 60, height: 60)

                Text(accessory.name)
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isEquipped ? Color.moodletPrimary.opacity(0.15) : Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEquipped ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct WardrobeBackgroundCard: View {
    let background: Background
    let isEquipped: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                BackgroundImage(background: background)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(background.name)
                    .font(.caption)
                    .foregroundStyle(Color.moodletTextPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isEquipped ? Color.moodletPrimary.opacity(0.15) : Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEquipped ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WardrobeView()
        .modelContainer(for: [
            Companion.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
