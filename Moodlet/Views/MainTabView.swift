//
//  MainTabView.swift
//  Moodlet
//

import SwiftUI

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
        .sheet(isPresented: $showMoodLogging) {
            MoodLoggingSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
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
