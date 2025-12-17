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
                ItemDetailSheet(item: item, userProfile: userProfile)
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

        // Seed with placeholder accessories
        let placeholderAccessories: [(String, AccessoryCategory, Int)] = [
            ("Cozy Beanie", .hat, 10),
            ("Party Hat", .hat, 15),
            ("Flower Crown", .hat, 20),
            ("Cool Shades", .glasses, 8),
            ("Round Glasses", .glasses, 12),
            ("Warm Scarf", .scarf, 10),
            ("Rainbow Scarf", .scarf, 25),
            ("Coffee Cup", .heldItem, 8),
            ("Tiny Book", .heldItem, 12),
            ("Cozy Sweater", .outfit, 30)
        ]

        for (name, category, price) in placeholderAccessories {
            let accessory = Accessory(
                name: name,
                imageName: "placeholder_\(category.rawValue)",
                category: category,
                price: price
            )
            modelContext.insert(accessory)
        }

        // Seed with placeholder backgrounds
        let placeholderBackgrounds: [(String, Int)] = [
            ("Cozy Room", 20),
            ("Sunny Garden", 25),
            ("Night Sky", 30),
            ("Beach Sunset", 35),
            ("Mountain View", 40)
        ]

        for (name, price) in placeholderBackgrounds {
            let background = Background(
                name: name,
                imageName: "placeholder_bg_\(name.lowercased().replacingOccurrences(of: " ", with: "_"))",
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
                ShopItemCard(
                    name: accessory.name,
                    price: accessory.price,
                    imageName: accessory.imageName,
                    isOwned: userProfile?.hasUnlockedAccessory(accessory.id) ?? false,
                    isPremiumOnly: accessory.isPremiumOnly,
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
                ShopItemCard(
                    name: background.name,
                    price: background.price,
                    imageName: background.imageName,
                    isOwned: userProfile?.hasUnlockedBackground(background.id) ?? false,
                    isPremiumOnly: background.isPremiumOnly,
                    isPremiumUser: userProfile?.isPremium ?? false,
                    isLargeCard: true
                ) {
                    onSelect(background)
                }
            }
        }
    }
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    let name: String
    let price: Int
    let imageName: String
    let isOwned: Bool
    let isPremiumOnly: Bool
    let isPremiumUser: Bool
    var isLargeCard: Bool = false
    let action: () -> Void

    private var isLocked: Bool {
        isPremiumOnly && !isPremiumUser
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Placeholder image
                ZStack {
                    RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                        .fill(Color.moodletBackground)
                        .aspectRatio(isLargeCard ? 1.5 : 1, contentMode: .fit)

                    Image(systemName: isLargeCard ? "photo" : "tshirt")
                        .font(.title)
                        .foregroundStyle(Color.moodletTextTertiary)

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

                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)
                    .lineLimit(1)

                if !isOwned {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(price)")
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

                // Placeholder for species icon
                Text(speciesEmoji)
                    .font(.system(size: 40))

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

// MARK: - Item Detail Sheet

struct ItemDetailSheet: View {
    let item: ShopItem
    let userProfile: UserProfile?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: MoodletTheme.largeSpacing) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius)
                        .fill(Color.moodletBackground)
                        .frame(height: 200)

                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(Color.moodletTextTertiary)
                }

                // Info
                VStack(spacing: 8) {
                    Text(itemName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.moodletTextPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("\(itemPrice)")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.moodletAccent)
                }

                Spacer()

                // Purchase button
                if !isOwned {
                    Button {
                        // Purchase logic
                        dismiss()
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

                    if !canAfford {
                        Text("You need \(itemPrice - (userProfile?.totalPoints ?? 0)) more points")
                            .font(.caption)
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                } else {
                    Text("You own this item!")
                        .font(.headline)
                        .foregroundStyle(Color.moodletPrimary)
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
