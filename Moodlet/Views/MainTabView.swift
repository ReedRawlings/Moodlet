//
//  MainTabView.swift
//  Moodlet
//

import SwiftUI
import SwiftData

enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case insights = 1
    case shop = 2
    case settings = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .insights: return "Insights"
        case .shop: return "Shop"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .insights: return "chart.bar.fill"
        case .shop: return "bag.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(\.appState) private var appState
    @State private var selectedTab: AppTab = .home
    @State private var showMoodLogging = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.icon, value: .home) {
                HomeView(showMoodLogging: $showMoodLogging)
            }

            Tab(AppTab.insights.title, systemImage: AppTab.insights.icon, value: .insights) {
                InsightsView()
            }

            Tab(AppTab.shop.title, systemImage: AppTab.shop.icon, value: .shop) {
                ShopView()
            }

            Tab(AppTab.settings.title, systemImage: AppTab.settings.icon, value: .settings) {
                SettingsView()
            }
        }
        .tint(.moodletPrimary)
        .overlay {
            if showMoodLogging {
                MoodLoggingOverlay(
                    isPresented: $showMoodLogging,
                    preSelectedEmotion: appState.pendingNotificationEmotion,
                    onDismiss: {
                        // Clear the pending emotion after dismissal
                        appState.pendingNotificationEmotion = nil
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showMoodLogging)
        .onChange(of: appState.showMoodLogging) { _, shouldShow in
            // Sync with appState (for notification-triggered opening)
            if shouldShow {
                showMoodLogging = true
                appState.showMoodLogging = false
            }
        }
        .onChange(of: appState.selectedTab) { _, newTab in
            // Sync tab selection from appState (for notification navigation)
            selectedTab = newTab
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            Companion.self,
            MoodEntry.self,
            UserProfile.self,
            Accessory.self,
            Background.self
        ], inMemory: true)
}
