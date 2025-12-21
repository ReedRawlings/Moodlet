//
//  ShopView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

struct ShopView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var accessories: [Accessory]
    @Query private var backgrounds: [Background]

    @State private var selectedCategory: ShopCategory = .accessories
    @State private var selectedAccessoryCategory: AccessoryCategory?
    @State private var selectedItem: ShopItem?

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    enum ShopCategory: String, CaseIterable, Identifiable {
        case accessories = "Accessories"
        case backgrounds = "Backgrounds"
        case species = "Species"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MoodletTheme.largeSpacing) {
                    // Points display
                    pointsHeader

                    // Category picker
                    categoryPicker

                    // Content
                    switch selectedCategory {
                    case .accessories:
                        accessoriesSection
                    case .backgrounds:
                        backgroundsSection
                    case .species:
                        speciesSection
                    }
                }
                .padding()
            }
            .background(Color.moodletBackground)
            .navigationTitle("Shop")
            .sheet(item: $selectedItem) { item in
                ItemDetailSheet(item: item)
            }
        }
        .onAppear {
            seedShopIfNeeded()
        }
    }

    // MARK: - Points Header

    private var pointsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Points")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.moodletAccent)
                    Text("\(userProfile?.totalPoints ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.moodletTextPrimary)
                }
            }

            Spacer()

            if userProfile?.isPremium == false {
                Button {
                    // Show premium upsell
                } label: {
                    Text("Go Premium")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.moodletAccent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(ShopCategory.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Accessories Section

    private var accessoriesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            // Subcategory filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MoodletTheme.smallSpacing) {
                    CategoryFilterChip(
                        title: "All",
                        isSelected: selectedAccessoryCategory == nil
                    ) {
                        selectedAccessoryCategory = nil
                    }

                    ForEach(AccessoryCategory.allCases) { category in
                        CategoryFilterChip(
                            title: category.displayName,
                            icon: category.icon,
                            isSelected: selectedAccessoryCategory == category
                        ) {
                            selectedAccessoryCategory = category
                        }
                    }
                }
            }

            // Accessories grid
            let filteredAccessories = selectedAccessoryCategory == nil
                ? accessories
                : accessories.filter { $0.category == selectedAccessoryCategory }

            if filteredAccessories.isEmpty {
                emptyStateView(message: "No accessories available yet")
            } else {
                AccessoryGridView(
                    accessories: filteredAccessories,
                    userProfile: userProfile
                ) { accessory in
                    selectedItem = .accessory(accessory)
                }
            }
        }
    }

    // MARK: - Backgrounds Section

    private var backgroundsSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            if backgrounds.isEmpty {
                emptyStateView(message: "No backgrounds available yet")
            } else {
                BackgroundGridView(
                    backgrounds: backgrounds,
                    userProfile: userProfile
                ) { background in
                    selectedItem = .background(background)
                }
            }
        }
    }

    // MARK: - Species Section

    private var speciesSection: some View {
        VStack(alignment: .leading, spacing: MoodletTheme.spacing) {
            Text("Unlock new Moodlet species!")
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: MoodletTheme.spacing) {
                ForEach(CompanionSpecies.allCases) { species in
                    SpeciesCard(
                        species: species,
                        isUnlocked: userProfile?.hasUnlockedSpecies(species) ?? false,
                        isPremium: species.isPremium
                    )
                }
            }
        }
    }

    // MARK: - Empty State

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: MoodletTheme.spacing) {
            Image(systemName: "bag")
                .font(.largeTitle)
                .foregroundStyle(Color.moodletTextTertiary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Seed Shop

    private func seedShopIfNeeded() {
        guard accessories.isEmpty else { return }

        // Seed with accessories (imageName matches asset naming: snake_case)
        let placeholderAccessories: [(String, String, AccessoryCategory, Int)] = [
            ("Cozy Beanie", "cozy_beanie", .hat, 10),
            ("Party Hat", "party_hat", .hat, 15),
            ("Flower Crown", "flower_crown", .hat, 20),
            ("Cool Shades", "cool_shades", .glasses, 8),
            ("Round Glasses", "round_glasses", .glasses, 12),
            ("Warm Scarf", "warm_scarf", .scarf, 10),
            ("Rainbow Scarf", "rainbow_scarf", .scarf, 25),
            ("Coffee Cup", "coffee_cup", .heldItem, 8),
            ("Tiny Book", "tiny_book", .heldItem, 12),
            ("Cozy Sweater", "cozy_sweater", .outfit, 30)
        ]

        for (name, imageName, category, price) in placeholderAccessories {
            let accessory = Accessory(
                name: name,
                imageName: imageName,
                category: category,
                price: price
            )
            modelContext.insert(accessory)
        }

        // Seed with backgrounds (imageName matches asset naming: snake_case)
        let placeholderBackgrounds: [(String, String, Int)] = [
            ("Cozy Room", "cozy_room", 20),
            ("Sunny Garden", "sunny_garden", 25),
            ("Night Sky", "night_sky", 30),
            ("Beach Sunset", "beach_sunset", 35),
            ("Mountain View", "mountain_view", 40)
        ]

        for (name, imageName, price) in placeholderBackgrounds {
            let background = Background(
                name: name,
                imageName: imageName,
                price: price
            )
            modelContext.insert(background)
        }
    }
}

// MARK: - Shop Item Enum

enum ShopItem: Identifiable {
    case accessory(Accessory)
    case background(Background)

    var id: UUID {
        switch self {
        case .accessory(let a): return a.id
        case .background(let b): return b.id
        }
    }
}

// MARK: - Category Filter Chip

struct CategoryFilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.moodletPrimary : Color.moodletSurface)
            .foregroundStyle(isSelected ? .white : Color.moodletTextPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Accessory Grid View

struct AccessoryGridView: View {
    let accessories: [Accessory]
    let userProfile: UserProfile?
    let onSelect: (Accessory) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: MoodletTheme.spacing) {
            ForEach(accessories) { accessory in
                AccessoryItemCard(
                    accessory: accessory,
                    isOwned: userProfile?.hasUnlockedAccessory(accessory.id) ?? false,
                    isPremiumUser: userProfile?.isPremium ?? false
                ) {
                    onSelect(accessory)
                }
            }
        }
    }
}

// MARK: - Background Grid View

struct BackgroundGridView: View {
    let backgrounds: [Background]
    let userProfile: UserProfile?
    let onSelect: (Background) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: MoodletTheme.spacing) {
            ForEach(backgrounds) { background in
                BackgroundItemCard(
                    background: background,
                    isOwned: userProfile?.hasUnlockedBackground(background.id) ?? false,
                    isPremiumUser: userProfile?.isPremium ?? false
                ) {
                    onSelect(background)
                }
            }
        }
    }
}

// MARK: - Accessory Item Card

struct AccessoryItemCard: View {
    let accessory: Accessory
    let isOwned: Bool
    let isPremiumUser: Bool
    let action: () -> Void

    private var isLocked: Bool {
        accessory.isPremiumOnly && !isPremiumUser
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Image with fallback
                ZStack {
                    RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                        .fill(Color.moodletBackground)
                        .aspectRatio(1, contentMode: .fit)

                    AccessoryImage(accessory: accessory, size: 50)

                    if isOwned {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.moodletPrimary)
                                    .padding(4)
                            }
                            Spacer()
                        }
                    }

                    if isLocked {
                        Color.black.opacity(0.3)
                            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))

                        Image(systemName: "lock.fill")
                            .foregroundStyle(.white)
                    }
                }

                Text(accessory.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)
                    .lineLimit(1)

                if !isOwned {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(accessory.price)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.moodletAccent)
                } else {
                    Text("Owned")
                        .font(.caption)
                        .foregroundStyle(Color.moodletPrimary)
                }
            }
            .padding(8)
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Background Item Card

struct BackgroundItemCard: View {
    let background: Background
    let isOwned: Bool
    let isPremiumUser: Bool
    let action: () -> Void

    private var isLocked: Bool {
        background.isPremiumOnly && !isPremiumUser
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Image with fallback
                ZStack {
                    RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                        .fill(Color.moodletBackground)
                        .aspectRatio(1.5, contentMode: .fit)
                        .overlay(
                            BackgroundImage(background: background)
                                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
                        )

                    if isOwned {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.moodletPrimary)
                                    .padding(4)
                            }
                            Spacer()
                        }
                    }

                    if isLocked {
                        Color.black.opacity(0.3)
                            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))

                        Image(systemName: "lock.fill")
                            .foregroundStyle(.white)
                    }
                }

                Text(background.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)
                    .lineLimit(1)

                if !isOwned {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(background.price)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.moodletAccent)
                } else {
                    Text("Owned")
                        .font(.caption)
                        .foregroundStyle(Color.moodletPrimary)
                }
            }
            .padding(8)
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Species Card

struct SpeciesCard: View {
    let species: CompanionSpecies
    let isUnlocked: Bool
    let isPremium: Bool

    var body: some View {
        VStack(spacing: MoodletTheme.smallSpacing) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.moodletPrimary.opacity(0.2) : Color.moodletBackground)
                    .frame(width: 80, height: 80)

                // Species image with fallback to placeholder
                CompanionImage(species: species, expression: "neutral", size: 70)

                if !isUnlocked && isPremium {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 80, height: 80)

                    Image(systemName: "lock.fill")
                        .foregroundStyle(.white)
                }
            }

            Text(species.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.moodletTextPrimary)

            Text(species.description)
                .font(.caption)
                .foregroundStyle(Color.moodletTextSecondary)
                .multilineTextAlignment(.center)

            if isUnlocked {
                Text("Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color.moodletPrimary)
            } else if isPremium {
                Text("Premium")
                    .font(.caption)
                    .foregroundStyle(Color.moodletAccent)
            } else {
                Text("Free")
                    .font(.caption)
                    .foregroundStyle(Color.moodletPrimary)
            }
        }
        .padding()
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
    }
}

// MARK: - Item Detail Sheet

struct ItemDetailSheet: View {
    let item: ShopItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    @Query private var companions: [Companion]
    @Query private var moodEntries: [MoodEntry]

    @State private var purchaseCompleted = false

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var companion: Companion? {
        companions.first
    }

    private let badgeService = BadgeService()

    var body: some View {
        NavigationStack {
            VStack(spacing: MoodletTheme.largeSpacing) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius)
                        .fill(Color.moodletBackground)
                        .frame(height: 200)

                    switch item {
                    case .accessory(let accessory):
                        AccessoryImage(accessory: accessory, size: 120)
                    case .background(let background):
                        BackgroundImage(background: background)
                            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))

                // Info
                VStack(spacing: 8) {
                    Text(itemName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.moodletTextPrimary)
                }

                Spacer()

                // Purchase or Equip buttons
                if purchaseCompleted || isOwned {
                    VStack(spacing: MoodletTheme.spacing) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.moodletPrimary)
                            Text("You own this item!")
                                .font(.headline)
                                .foregroundStyle(Color.moodletPrimary)
                        }

                        // Equip/Unequip button
                        if let companion = companion {
                            if isEquipped {
                                Button {
                                    performUnequip(companion: companion)
                                } label: {
                                    Text("Unequip")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.moodletBackground)
                                        .foregroundStyle(Color.moodletTextPrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                                }
                            } else {
                                Button {
                                    performEquip(companion: companion)
                                } label: {
                                    HStack {
                                        Image(systemName: "tshirt.fill")
                                        Text("Equip")
                                    }
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.moodletPrimary)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                                }
                            }
                        }
                    }
                } else {
                    if !canAfford {
                        Text("You need \(itemPrice - (userProfile?.totalPoints ?? 0)) more points")
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                    
                    Button {
                        performPurchase()
                    } label: {
                        HStack {
                            Text("Purchase")
                            Image(systemName: "star.fill")
                            Text("\(itemPrice)")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAfford ? Color.moodletPrimary : Color.moodletPrimary.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
                    }
                    .disabled(!canAfford)
                }
            }
            .padding()
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func performPurchase() {
        guard let profile = userProfile else { return }
        guard profile.totalPoints >= itemPrice else { return }

        // Deduct points
        profile.totalPoints -= itemPrice

        // Add item to unlocked list
        switch item {
        case .accessory(let accessory):
            if !profile.unlockedAccessoryIDs.contains(accessory.id) {
                profile.unlockedAccessoryIDs.append(accessory.id)
            }
        case .background(let background):
            if !profile.unlockedBackgroundIDs.contains(background.id) {
                profile.unlockedBackgroundIDs.append(background.id)
            }
        }

        // Check for first purchase badge
        badgeService.checkPurchaseBadge(profile: profile)

        withAnimation {
            purchaseCompleted = true
        }
    }

    private var itemName: String {
        switch item {
        case .accessory(let a): return a.name
        case .background(let b): return b.name
        }
    }

    private var itemPrice: Int {
        switch item {
        case .accessory(let a): return a.price
        case .background(let b): return b.price
        }
    }

    private var isOwned: Bool {
        switch item {
        case .accessory(let a): return userProfile?.hasUnlockedAccessory(a.id) ?? false
        case .background(let b): return userProfile?.hasUnlockedBackground(b.id) ?? false
        }
    }

    private var canAfford: Bool {
        (userProfile?.totalPoints ?? 0) >= itemPrice
    }

    private var isEquipped: Bool {
        switch item {
        case .accessory(let a):
            return companion?.equippedAccessories.contains { $0.id == a.id } ?? false
        case .background(let b):
            return companion?.equippedBackground?.id == b.id
        }
    }

    private func performEquip(companion: Companion) {
        switch item {
        case .accessory(let accessory):
            if !companion.equippedAccessories.contains(where: { $0.id == accessory.id }) {
                companion.equippedAccessories.append(accessory)
            }
        case .background(let background):
            companion.equippedBackground = background
        }

        // Check for dress up badge
        if let profile = userProfile {
            badgeService.checkDressUpBadge(profile: profile, companion: companion)
        }
    }

    private func performUnequip(companion: Companion) {
        switch item {
        case .accessory(let accessory):
            companion.equippedAccessories.removeAll { $0.id == accessory.id }
        case .background:
            companion.equippedBackground = nil
        }
    }
}

#Preview {
    ShopView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
