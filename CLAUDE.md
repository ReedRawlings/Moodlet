# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moodlet is an iOS mood-tracking app with an animal companion that reflects emotional patterns. Built with **SwiftUI + SwiftData**, targeting **iOS 26+** with iCloud sync via CloudKit.

## Build & Run

This is an Xcode project (no SPM/CocoaPods). Open `Moodlet.xcodeproj` in Xcode 26.1.1+ and run on simulator or device.

```bash
# Build from command line
xcodebuild -project Moodlet.xcodeproj -scheme Moodlet -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (when added)
xcodebuild -project Moodlet.xcodeproj -scheme Moodlet -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

**MVVM with SwiftData** - Uses iOS 26's `@Observable` macro (not @StateObject):

```
Views (@Query, @Environment) → Services (@Observable) → Models (@Model SwiftData)
```

- **Models/** - SwiftData `@Model` classes: `MoodEntry`, `UserProfile`, `Companion`, `Accessory`, `Background`
- **Services/** - Business logic: `DataService` (CRUD), `PointsService`, `StreakService`, `NotificationService`, `ExportService`
- **Views/** - SwiftUI views organized by tab: `Home/`, `Insights/`, `Shop/`, `Settings/`
- **App/** - `AppState` (observable UI state), `DependencyContainer` (singleton service locator)
- **Utilities/** - `Constants`, `ColorPalette`, `DateExtensions`, `MoodletError`

## Key Patterns

### Data Flow
- `@Query` macros in views for reactive SwiftData binding
- `@Environment(\.modelContext)` for data modifications
- Services are stateless business logic accessed via `DependencyContainer.shared`

### SwiftData Models
Schema configured in `MoodletApp.swift` with CloudKit sync (`.automatic`). Models auto-migrate.

### Points System (Constants.Points)
- Mood log: 1pt, Activity tags: 1pt, Journal: 2pt
- Max 3 point-earning entries per day
- Streak bonuses at 3/7/14/30/100 days (2/5/10/15/25 pts)
- 48-hour grace period before streak resets

## File Quick Reference

| Task | Key Files |
|------|-----------|
| Mood entry flow | `HomeView.swift`, `MoodLoggingSheet.swift`, `DataService.swift` |
| Points/streaks | `PointsService.swift`, `StreakService.swift`, `Constants.swift` |
| Shop | `ShopView.swift`, `Accessory.swift`, `Background.swift` |
| Styling | `ColorPalette.swift` (brand colors, MoodletTheme dimensions) |
| Companion | `Companion.swift`, `CompanionView.swift` |

## Brand Colors

- Primary: `#2e8b57` (Sea Green)
- Accent: `#b08d57` (Bronze)
- Background: `#f3eff5` (Light Lavender)
- Mood colors: Happy `#FFD93D`, Content `#6BCB77`, Neutral `#B08D57`, Annoyed `#FF8C42`, Sad `#4D96FF`

## Asset Naming & Layering System

Companions use a **layered rendering system** - one base image per species with accessories stacked on top.

### Asset Structure
```
Assets.xcassets/
├── Companions/           # One image per species: cat, bear, bunny, frog, fox, penguin
│   └── {species}.imageset/
├── Accessories/          # Layered on top of companion
│   ├── Eyes/            # Expression overlays (happy_eyes, sleepy_eyes)
│   ├── Tops/            # Clothing (cozy_sweater, striped_shirt)
│   ├── Glasses/         # Eyewear (cool_shades, round_glasses)
│   ├── Hats/            # Headwear (cozy_beanie, party_hat)
│   └── HeldItems/       # Items held (coffee_cup, tiny_book)
└── Backgrounds/         # Scene backgrounds
```

### Layer Order (bottom to top)
1. Base Companion → 2. Eyes → 3. Top → 4. Glasses → 5. Hat → 6. Held Item

### Naming Pattern
| Type | Pattern | Example |
|------|---------|---------|
| Companion | `Companions/{species}` | `Companions/cat` |
| Accessory | `Accessories/{Category}/{name}` | `Accessories/Hats/cozy_beanie` |
| Background | `Backgrounds/{name}` | `Backgrounds/cozy_room` |

## Documentation

Detailed specs in `Moodlet/`:
- `moodlet-prd-updated.md` - Product requirements
- `moodlet-technical-spec.md` - Implementation reference
