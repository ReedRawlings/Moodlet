# Moodlet Technical Specification
## Version 1.1 — Phase 1 MVP

---

## Implementation Status

> **Last Updated:** December 17, 2025

### ✅ Completed

| Component | Status | Notes |
|-----------|--------|-------|
| **Project Structure** | ✅ Done | MVVM folders created (App, Models, Views, Services, Utilities) |
| **Data Models** | ✅ Done | Companion, MoodEntry, UserProfile, Accessory, Background, ActivityTag |
| **SwiftData Setup** | ✅ Done | ModelContainer with iCloud sync configured |
| **Main TabView** | ✅ Done | iOS 26 Tab API with 4 tabs (Home, Insights, Shop, Settings) |
| **Home View** | ✅ Done | Companion display, mood logging button, today's entries, stats |
| **Mood Logging Sheet** | ✅ Done | 3-step flow (mood → tags → journal), points calculation |
| **Insights View** | ✅ Done | Mood calendar, timeframe picker, mood-activity/people relationships, time of day analysis |
| **Mood Calendar** | ✅ Done | "Year in Pixels" style with month navigation |
| **Shop View** | ✅ Done | Categories (accessories, backgrounds, species), placeholder inventory |
| **Settings View** | ✅ Done | Notifications, export, data management, premium, about |
| **Points Service** | ✅ Done | Point calculation, daily caps, streak bonuses |
| **Streak Service** | ✅ Done | 48-hour grace period, milestone detection |
| **Notification Service** | ✅ Done | Permission handling, scheduling, message variations |
| **Export Service** | ✅ Done | CSV and JSON export |
| **Color Palette** | ✅ Done | Brand colors applied (#2e8b57, #b08d57, #393d3f, #f3eff5, #fcfffc) |
| **Constants** | ✅ Done | Points, streaks, shop prices, notification messages |
| **Date Extensions** | ✅ Done | Helper methods for calendar operations |

### 🚧 In Progress / Next Focus

| Component | Priority | Notes |
|-----------|----------|-------|
| **Onboarding Flow** | HIGH | Egg hatching, companion creation, first mood log |
| **Companion Assets** | HIGH | Placeholder currently; need actual sprites |
| **Companion Animation System** | MEDIUM | Framework exists, needs sprite integration |
| **StoreKit Integration** | MEDIUM | UI exists, needs App Store Connect setup |
| **Accessibility** | MEDIUM | VoiceOver labels, Dynamic Type testing |
| **Dark Mode** | LOW | Colors defined, needs testing |

### 📋 Deferred to Phase 2+

- Apple Intelligence / Foundation Models integration
- Widgets (Home Screen, Lock Screen)
- Siri Shortcuts / App Intents
- Weekly review feature
- Advanced insights (correlations, time-of-day patterns)
- HealthKit integration
- Watch app

---

## Overview

This document defines the technical architecture and implementation details for Moodlet Phase 1. It should be read alongside the Product Requirements Document (PRD) and used as the primary reference for development.

**Target Platform:** iOS 26+
**Architecture:** MVVM with SwiftUI
**Data Layer:** SwiftData with iCloud Sync
**Language:** Swift 6

---

## App Architecture

### Pattern: MVVM

```
┌─────────────────────────────────────────────────────┐
│                      Views                          │
│   (SwiftUI Views - UI only, no business logic)      │
└─────────────────────┬───────────────────────────────┘
                      │ @StateObject / @ObservedObject
┌─────────────────────▼───────────────────────────────┐
│                  ViewModels                         │
│   (ObservableObject classes - presentation logic)   │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                   Services                          │
│   (Data, Notifications, StoreKit, CloudKit)         │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                    Models                           │
│   (SwiftData @Model classes)                        │
└─────────────────────────────────────────────────────┘
```

### Project Structure

```
Moodlet/
├── App/
│   ├── MoodletApp.swift
│   ├── AppState.swift
│   └── DependencyContainer.swift
│
├── Models/
│   ├── MoodEntry.swift
│   ├── Companion.swift
│   ├── Accessory.swift
│   ├── Background.swift
│   ├── ActivityTag.swift
│   └── UserProfile.swift
│
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── MoodLoggingViewModel.swift
│   ├── InsightsViewModel.swift
│   ├── ShopViewModel.swift
│   ├── SettingsViewModel.swift
│   └── OnboardingViewModel.swift
│
├── Views/
│   ├── MainTabView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── CompanionView.swift
│   │   └── MoodLoggingSheet.swift
│   ├── Insights/
│   │   ├── InsightsView.swift
│   │   ├── MoodCalendarView.swift
│   │   └── TrendsView.swift
│   ├── Shop/
│   │   ├── ShopView.swift
│   │   ├── AccessoryGridView.swift
│   │   └── ItemDetailView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── NotificationSettingsView.swift
│   │   └── ExportView.swift
│   └── Onboarding/
│       ├── OnboardingContainerView.swift
│       ├── WelcomeView.swift
│       ├── FirstMoodView.swift
│       ├── EggHatchingView.swift
│       ├── CompanionNamingView.swift
│       └── NotificationSetupView.swift
│
├── Services/
│   ├── DataService.swift
│   ├── NotificationService.swift
│   ├── PointsService.swift
│   ├── StreakService.swift
│   ├── PurchaseService.swift
│   └── ExportService.swift
│
├── Components/
│   ├── MoodFaceButton.swift
│   ├── ActivityTagChip.swift
│   ├── PointsBadge.swift
│   └── AnimatedCompanion.swift
│
├── Utilities/
│   ├── Constants.swift
│   ├── DateExtensions.swift
│   └── ColorPalette.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── CompanionAnimations/
    │   ├── Cat/
    │   ├── Bear/
    │   ├── Bunny/
    │   ├── Frog/
    │   ├── Fox/
    │   └── Penguin/
    └── Localizable.strings
```

---

## Navigation Structure

### Tab Bar

| Tab | Icon | Root View | Purpose |
|-----|------|-----------|---------|
| Home | house.fill | HomeView | Companion display + mood logging |
| Insights | chart.bar.fill | InsightsView | Calendar, trends, patterns |
| Shop | bag.fill | ShopView | Accessories, backgrounds, species |
| Settings | gearshape.fill | SettingsView | Preferences, export, premium |

### Navigation Flow

```
App Launch
    │
    ├── First Launch → OnboardingContainerView
    │                      ├── WelcomeView
    │                      ├── FirstMoodView (logs first mood)
    │                      ├── EggHatchingView
    │                      ├── CompanionNamingView
    │                      └── NotificationSetupView
    │                              │
    │                              ▼
    └── Returning User ──────→ MainTabView
                                   ├── HomeView
                                   │      └── MoodLoggingSheet (modal)
                                   ├── InsightsView
                                   │      └── EntryDetailView (push)
                                   ├── ShopView
                                   │      └── ItemDetailView (push)
                                   └── SettingsView
                                          ├── NotificationSettingsView (push)
                                          ├── ExportView (push)
                                          └── PremiumView (push)
```

---

## Data Model

### SwiftData Schema

```swift
// MARK: - Companion

@Model
final class Companion {
    @Attribute(.unique) var id: UUID
    var name: String
    var species: CompanionSpecies
    var pronouns: Pronouns
    var baseColor: String // Hex color from egg selection
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

enum CompanionSpecies: String, Codable, CaseIterable {
    case cat, bear, bunny, frog, fox, penguin
    
    var isPremium: Bool {
        self != .cat
    }
}

enum Pronouns: String, Codable, CaseIterable {
    case they, she, he, custom
}

// MARK: - Mood Entry

@Model
final class MoodEntry {
    @Attribute(.unique) var id: UUID
    var mood: Mood
    var timestamp: Date
    var note: String? // Journal reflection
    var activityTags: [String] // Stored as string identifiers
    var earnedPoints: Bool // Whether this entry counted toward daily point cap
    
    init(mood: Mood, note: String? = nil, activityTags: [String] = [], earnedPoints: Bool = false) {
        self.id = UUID()
        self.mood = mood
        self.timestamp = Date()
        self.note = note
        self.activityTags = activityTags
        self.earnedPoints = earnedPoints
    }
}

enum Mood: String, Codable, CaseIterable {
    case happy
    case content
    case annoyed
    case mad
    case sad
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: String { // Hex colors for mood calendar
        switch self {
        case .happy: return "#FFD93D"    // Yellow
        case .content: return "#6BCB77"  // Green
        case .annoyed: return "#FF8C42"  // Orange
        case .mad: return "#E84545"      // Red
        case .sad: return "#4D96FF"      // Blue
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "face.smiling.fill"
        case .content: return "face.smiling"
        case .annoyed: return "face.smiling.inverse"
        case .mad: return "exclamationmark.triangle.fill"
        case .sad: return "cloud.rain.fill"
        }
    }
}

// MARK: - User Profile

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastLogDate: Date?
    var streakGraceUsed: Bool // Tracks if 48hr grace period is active
    var onboardingCompleted: Bool
    var onboardingStep: Int // For resume functionality
    var notificationTimes: [Date] // Scheduled notification times
    var isPremium: Bool
    var premiumExpirationDate: Date?
    
    // Unlocked content
    var unlockedAccessoryIDs: [UUID]
    var unlockedBackgroundIDs: [UUID]
    var unlockedSpecies: [String] // CompanionSpecies raw values
    
    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastLogDate = nil
        self.streakGraceUsed = false
        self.onboardingCompleted = false
        self.onboardingStep = 0
        self.notificationTimes = []
        self.isPremium = false
        self.premiumExpirationDate = nil
        self.unlockedAccessoryIDs = []
        self.unlockedBackgroundIDs = []
        self.unlockedSpecies = [CompanionSpecies.cat.rawValue]
    }
}

// MARK: - Shop Items

@Model
final class Accessory {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageName: String
    var category: AccessoryCategory
    var price: Int
    var isPremiumOnly: Bool
    var requiredStreakMilestone: Int? // nil if no streak requirement
    
    init(name: String, imageName: String, category: AccessoryCategory, price: Int, isPremiumOnly: Bool = false, requiredStreakMilestone: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.category = category
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = requiredStreakMilestone
    }
}

enum AccessoryCategory: String, Codable, CaseIterable {
    case eyes, glasses, hat, top, heldItem = "held_item"

    /// Layer order for rendering (lower = rendered first/behind)
    var layerOrder: Int {
        switch self {
        case .eyes: return 1      // Base expression layer
        case .top: return 2       // Clothing layer
        case .glasses: return 3   // Eyewear layer
        case .hat: return 4       // Headwear layer
        case .heldItem: return 5  // Items held (front)
        }
    }
}

@Model
final class Background {
    @Attribute(.unique) var id: UUID
    var name: String
    var imageName: String
    var price: Int
    var isPremiumOnly: Bool
    var requiredStreakMilestone: Int?
    
    init(name: String, imageName: String, price: Int, isPremiumOnly: Bool = false, requiredStreakMilestone: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.price = price
        self.isPremiumOnly = isPremiumOnly
        self.requiredStreakMilestone = requiredStreakMilestone
    }
}
```

### iCloud Sync Configuration

```swift
// In MoodletApp.swift
@main
struct MoodletApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], isAutosaveEnabled: true, isUndoEnabled: false)
    }
}
```

SwiftData with CloudKit will handle sync automatically. No additional CloudKit configuration needed beyond enabling the capability in Xcode.

---

## Points System

### Earning Rules

| Action | Points | Limit |
|--------|--------|-------|
| Log mood | 1 | Max 3 per day |
| Add context tags | 1 | Only on point-eligible entries |
| Write reflection | 2 | Only on point-eligible entries |
| Complete weekly review | 3 | Once per week |

### Daily Point Cap Logic

```swift
class PointsService {
    private let maxDailyPointEntries = 3
    
    func canEarnPoints(on date: Date, entries: [MoodEntry]) -> Bool {
        let todayEntries = entries.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
        let pointEarningEntries = todayEntries.filter { $0.earnedPoints }
        return pointEarningEntries.count < maxDailyPointEntries
    }
    
    func calculatePointsForEntry(moodLogged: Bool, tagsAdded: Bool, reflectionWritten: Bool) -> Int {
        var points = 0
        if moodLogged { points += 1 }
        if tagsAdded { points += 1 }
        if reflectionWritten { points += 2 }
        return points
    }
}
```

### Streak Logic

```swift
class StreakService {
    private let gracePeriodHours = 48
    
    func updateStreak(for profile: UserProfile, newEntryDate: Date) {
        guard let lastLog = profile.lastLogDate else {
            // First ever entry
            profile.currentStreak = 1
            profile.lastLogDate = newEntryDate
            return
        }
        
        let calendar = Calendar.current
        let daysSinceLastLog = calendar.dateComponents([.day], from: lastLog, to: newEntryDate).day ?? 0
        
        switch daysSinceLastLog {
        case 0:
            // Same day, no streak change
            break
        case 1:
            // Consecutive day
            profile.currentStreak += 1
            profile.streakGraceUsed = false
        case 2:
            // Within grace period
            if !profile.streakGraceUsed {
                profile.currentStreak += 1
                profile.streakGraceUsed = true
            } else {
                profile.currentStreak = 1
                profile.streakGraceUsed = false
            }
        default:
            // Streak broken
            profile.currentStreak = 1
            profile.streakGraceUsed = false
        }
        
        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        profile.lastLogDate = newEntryDate
    }
}
```

### Streak Milestones & Rewards

| Milestone | Bonus Points | Unlock |
|-----------|--------------|--------|
| 3 days | +2 | — |
| 7 days | +5 | "Week Warrior" badge |
| 14 days | +10 | Streak-exclusive shop section |
| 30 days | +15 | "Month Milestone" cosmetic |
| 100 days | +25 | Rare companion animation |

---

## Companion & Accessory Layering System

### Overview

Each companion is rendered as a **single base image** with **accessories layered on top** in a specific order. This allows users to customize their companion's appearance by unlocking and equipping accessories from the shop.

### Asset Structure

```
Assets.xcassets/
├── Companions/                    # One image per species
│   ├── cat.imageset/
│   ├── bear.imageset/
│   ├── bunny.imageset/
│   ├── frog.imageset/
│   ├── fox.imageset/
│   └── penguin.imageset/
│
├── Accessories/                   # Layered on top of companion
│   ├── Eyes/                      # Expression overlays (happy_eyes, sleepy_eyes, etc.)
│   ├── Tops/                      # Clothing (cozy_sweater, striped_shirt, etc.)
│   ├── Glasses/                   # Eyewear (cool_shades, round_glasses, etc.)
│   ├── Hats/                      # Headwear (cozy_beanie, party_hat, etc.)
│   └── HeldItems/                 # Items companion holds (coffee_cup, tiny_book, etc.)
│
└── Backgrounds/                   # Scene backgrounds
    └── (various backgrounds)
```

### Naming Conventions

| Asset Type | Pattern | Example |
|------------|---------|---------|
| Companion | `Companions/{species}` | `Companions/cat` |
| Accessory | `Accessories/{Category}/{image_name}` | `Accessories/Hats/cozy_beanie` |
| Background | `Backgrounds/{image_name}` | `Backgrounds/cozy_room` |

### Rendering Order (Layer Stack)

Accessories are rendered in `layerOrder` from lowest to highest:

| Layer | Category | Purpose |
|-------|----------|---------|
| 0 | Base Companion | The species base image |
| 1 | Eyes | Expression overlays (happy, sleepy, heart eyes, etc.) |
| 2 | Top | Clothing items (sweaters, shirts) |
| 3 | Glasses | Eyewear items |
| 4 | Hat | Headwear items |
| 5 | Held Item | Items the companion holds (rendered in front) |

### Rendering Implementation

```swift
// In CompanionView.swift
ZStack {
    // Base companion image
    CompanionImage(species: companion.species, size: 140)

    // Equipped accessories layered in order
    ForEach(companion.equippedAccessories.sorted { $0.category.layerOrder < $1.category.layerOrder }) { accessory in
        AccessoryImage(accessory: accessory, size: 140)
    }
}
```

### Design Guidelines for Assets

1. **All assets should be the same dimensions** (e.g., 280x280 for @2x) to layer correctly
2. **Companions should have transparent areas** where accessories will be placed
3. **Accessories should have transparent backgrounds** and be positioned to align with companion
4. **Consider all 6 species** when designing accessories - they should work across body shapes

---

## Notifications

### Scheduling

```swift
class NotificationService {
    func scheduleNotifications(times: [Date]) async throws {
        let center = UNUserNotificationCenter.current()
        
        // Clear existing
        center.removeAllPendingNotificationRequests()
        
        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Moodlet"
            content.body = notificationMessage(for: index)
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "moodlet_checkin_\(index)",
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        }
    }
    
    private func notificationMessage(for timeSlot: Int) -> String {
        let messages = [
            ["Good morning — how are you starting the day?", "Morning check-in time ☀️", "Rise and shine — how are you feeling?"],
            ["Afternoon check-in — how's it going?", "Midday moment — how are you?", "Taking a pause — how's your day?"],
            ["Winding down — how was today?", "Evening reflection time 🌙", "End of day — how are you feeling?"]
        ]
        let slot = min(timeSlot, messages.count - 1)
        return messages[slot].randomElement() ?? "Your Moodlet is here when you're ready"
    }
}
```

### In-App Reminder for Low Engagement

```swift
// In HomeViewModel
func checkShouldShowNotificationReminder() -> Bool {
    guard !notificationService.hasPermission else { return false }
    
    let recentEntries = dataService.entries(from: Date().addingTimeInterval(-7 * 24 * 60 * 60))
    let entriesThisWeek = recentEntries.count
    
    // Show reminder if less than 3 entries this week and haven't dismissed recently
    return entriesThisWeek < 3 && !hasRecentlyDismissedReminder
}
```

---

## StoreKit 2 Integration

### Product Definitions

```swift
enum MoodletProduct: String, CaseIterable {
    case monthlyPremium = "com.moodlet.premium.monthly"
    case annualPremium = "com.moodlet.premium.annual"
    case lifetimePremium = "com.moodlet.premium.lifetime"
    case speciesPack = "com.moodlet.species.all"
    case cosmeticsPack = "com.moodlet.cosmetics.deluxe"
}
```

### Purchase Service

```swift
class PurchaseService: ObservableObject {
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPremium: Bool = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task { await updatePurchasedProducts() }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
        isPremium = purchased.contains(MoodletProduct.monthlyPremium.rawValue) ||
                    purchased.contains(MoodletProduct.annualPremium.rawValue) ||
                    purchased.contains(MoodletProduct.lifetimePremium.rawValue)
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await updatePurchasedProducts()
                await transaction.finish()
                return transaction
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
        return nil
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
}
```

---

## Data Export

### CSV Export

```swift
class ExportService {
    func exportToCSV(entries: [MoodEntry]) -> URL? {
        var csv = "Date,Time,Mood,Activities,Reflection\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for entry in entries.sorted(by: { $0.timestamp < $1.timestamp }) {
            let date = dateFormatter.string(from: entry.timestamp)
            let time = timeFormatter.string(from: entry.timestamp)
            let mood = entry.mood.displayName
            let activities = entry.activityTags.joined(separator: "; ")
            let reflection = (entry.note ?? "").replacingOccurrences(of: ",", with: ";")
                                               .replacingOccurrences(of: "\n", with: " ")
            
            csv += "\(date),\(time),\(mood),\"\(activities)\",\"\(reflection)\"\n"
        }
        
        let fileName = "moodlet_export_\(dateFormatter.string(from: Date())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            return nil
        }
    }
}
```

---

## Activity Tags

### Default Tags

```swift
enum DefaultActivityTag: String, CaseIterable {
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
    case weather_good = "Good Weather"
    case weather_bad = "Bad Weather"
    
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
        case .weather_good: return "sun.max.fill"
        case .weather_bad: return "cloud.rain.fill"
        }
    }
}
```

---

## Onboarding State Persistence

### Resume Logic

```swift
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep
    
    private var userProfile: UserProfile
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case firstMood = 1
        case activityTags = 2
        case eggColor = 3
        case hatchEgg = 4
        case nameCompanion = 5
        case setPronouns = 6
        case notificationSetup = 7
        case complete = 8
    }
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self.currentStep = OnboardingStep(rawValue: userProfile.onboardingStep) ?? .welcome
    }
    
    func advanceStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        currentStep = nextStep
        userProfile.onboardingStep = nextStep.rawValue
    }
    
    private func completeOnboarding() {
        userProfile.onboardingCompleted = true
        userProfile.onboardingStep = OnboardingStep.complete.rawValue
    }
}
```

---

## Constants

```swift
enum Constants {
    enum Points {
        static let moodLog = 1
        static let contextTags = 1
        static let reflection = 2
        static let weeklyReview = 3
        static let maxDailyPointEntries = 3
    }
    
    enum Streaks {
        static let gracePeriodDays = 2
        static let milestone3Day = 3
        static let milestone7Day = 7
        static let milestone14Day = 14
        static let milestone30Day = 30
        static let milestone100Day = 100
    }
    
    enum Animation {
        static let frameRate: TimeInterval = 1.0 / 12.0
        static let idleFrameCount = 24
    }
    
    enum Shop {
        static let cheapItemRange = 5...15
        static let midItemRange = 20...40
        static let premiumItemRange = 50...100
    }
}
```

---

## Error Handling

### App-Wide Error Types

```swift
enum MoodletError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case exportFailed
    case purchaseFailed
    case notificationPermissionDenied
    case cloudSyncFailed
    
    var errorDescription: String? {
        switch self {
        case .dataLoadFailed: return "Unable to load your data"
        case .dataSaveFailed: return "Unable to save your entry"
        case .exportFailed: return "Export failed"
        case .purchaseFailed: return "Purchase could not be completed"
        case .notificationPermissionDenied: return "Notification permission needed"
        case .cloudSyncFailed: return "Unable to sync with iCloud"
        }
    }
}
```

---

## Dependencies

### Apple Frameworks Only (Phase 1)

| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI layer |
| SwiftData | Data persistence |
| CloudKit | iCloud sync (via SwiftData) |
| StoreKit | In-app purchases |
| UserNotifications | Local notifications |

### Potential Additions (Post-MVP)

| Package | Purpose | When |
|---------|---------|------|
| TelemetryDeck | Privacy-focused analytics | If analytics needed |

---

## Performance Targets

| Metric | Target |
|--------|--------|
| App launch (cold) | < 2 seconds |
| Mood log save | < 100ms |
| Animation frame rate | 12 FPS consistent |
| App size | < 100 MB |

---

## Open Items for Development

- [x] ~~Create default shop inventory (10+ accessories, 5+ backgrounds)~~ — Done (10 accessories, 5 backgrounds seeded)
- [x] ~~Finalize notification copy library (20+ variations)~~ — Done (15+ messages across morning/afternoon/evening/neutral)
- [ ] Confirm companion base colors available during egg selection — Needs design input
- [ ] Define weekly review flow and content — Deferred to post-onboarding
- [ ] Create onboarding flow views (WelcomeView, EggHatchingView, etc.)
- [ ] Add companion sprite assets (Cat minimum for MVP)
- [ ] Implement companion animation controller with real assets
- [ ] Set up App Store Connect for StoreKit testing
- [ ] Add VoiceOver accessibility labels
- [ ] Test Dynamic Type scaling
- [ ] Implement haptic feedback on interactions

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 16, 2025 | Initial technical specification |
| 1.1 | Dec 17, 2025 | Added implementation status; marked completed items |
