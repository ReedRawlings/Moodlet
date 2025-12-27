//
//  PremiumFeatureGate.swift
//  Moodlet
//
//  View components for premium features and paywall
//

import SwiftUI
import StoreKit

// MARK: - Premium Feature Check
struct PremiumFeatureGate<PremiumContent: View, FreeContent: View>: View {
    private var storeManager = StoreKitManager.shared

    let premiumContent: () -> PremiumContent
    let freeContent: () -> FreeContent

    init(
        @ViewBuilder premium: @escaping () -> PremiumContent,
        @ViewBuilder free: @escaping () -> FreeContent
    ) {
        self.premiumContent = premium
        self.freeContent = free
    }

    var body: some View {
        if storeManager.isPremium {
            premiumContent()
        } else {
            freeContent()
        }
    }
}

// MARK: - Premium Lock Overlay
struct PremiumLockOverlay: View {
    let featureName: String
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.moodletPrimary, .moodletAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Premium Feature")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.moodletTextPrimary)

            Text("\(featureName) is available with Premium")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.moodletTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                    Text("Upgrade to Premium")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.moodletPrimary, .moodletAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(Color.moodletSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - View Modifier for Premium Gating
struct PremiumGatedModifier: ViewModifier {
    private var storeManager = StoreKitManager.shared
    @State private var showingUpgradeSheet: Bool = false

    let featureName: String
    let requiresPremium: Bool

    init(featureName: String, requiresPremium: Bool) {
        self.featureName = featureName
        self.requiresPremium = requiresPremium
    }

    func body(content: Content) -> some View {
        Group {
            if requiresPremium && !storeManager.isPremium {
                content
                    .disabled(true)
                    .overlay {
                        Color.moodletBackground.opacity(0.8)
                            .ignoresSafeArea()
                    }
                    .overlay {
                        PremiumLockOverlay(featureName: featureName) {
                            showingUpgradeSheet = true
                        }
                    }
            } else {
                content
            }
        }
        .sheet(isPresented: $showingUpgradeSheet) {
            UpgradeSheet()
        }
    }
}

// MARK: - Upgrade Sheet
struct UpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss
    private var storeManager = StoreKitManager.shared
    @State private var selectedProductId: String?
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moodletBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.moodletPrimary, .moodletAccent],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            Text("Moodlet Premium")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.moodletTextPrimary)

                            Text("Unlock the full experience")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.moodletTextSecondary)
                        }
                        .padding(.top, 24)

                        // Features
                        VStack(alignment: .leading, spacing: 12) {
                            premiumFeature("All 6 Moodlet species")
                            premiumFeature("100+ exclusive accessories")
                            premiumFeature("Seasonal exclusive items")
                            premiumFeature("Advanced insights & patterns")
                            premiumFeature("iCloud backup & sync")
                        }
                        .padding(20)
                        .background(Color.moodletSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)

                        // Plans
                        VStack(spacing: 12) {
                            if let yearly = storeManager.yearlyProduct {
                                UpgradePlanOption(
                                    product: yearly,
                                    isSelected: selectedProductId == yearly.id,
                                    badge: "Save 50%",
                                    subtitle: storeManager.formattedPricePerMonth(for: yearly).map { "\($0)/month" },
                                    onTap: { selectedProductId = yearly.id }
                                )
                            }

                            if let monthly = storeManager.monthlyProduct {
                                UpgradePlanOption(
                                    product: monthly,
                                    isSelected: selectedProductId == monthly.id,
                                    badge: nil,
                                    subtitle: nil,
                                    onTap: { selectedProductId = monthly.id }
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Purchase Button
                        Button(action: purchase) {
                            HStack {
                                if isPurchasing || storeManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Continue")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.moodletPrimary, .moodletAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(selectedProductId == nil || isPurchasing || storeManager.isLoading)
                        .padding(.horizontal, 20)

                        // Restore
                        Button("Restore Purchases") {
                            Task {
                                await storeManager.restorePurchases()
                                if storeManager.isPremium {
                                    dismiss()
                                }
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.moodletTextSecondary)

                        // Legal
                        Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                            .font(.caption2)
                            .foregroundStyle(Color.moodletTextTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.moodletTextSecondary)
                    }
                }
            }
        }
        .onAppear {
            if let yearly = storeManager.yearlyProduct {
                selectedProductId = yearly.id
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func premiumFeature(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.moodletPrimary)
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.moodletTextPrimary)
        }
    }

    private func purchase() {
        guard let productId = selectedProductId,
              let product = storeManager.products.first(where: { $0.id == productId }) else {
            return
        }

        Task {
            isPurchasing = true
            do {
                _ = try await storeManager.purchase(product)
                isPurchasing = false
                dismiss()
            } catch StoreError.userCancelled {
                isPurchasing = false
            } catch {
                isPurchasing = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Upgrade Plan Option
struct UpgradePlanOption: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let subtitle: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.moodletTextPrimary)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.moodletAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    HStack(spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.moodletTextSecondary)

                        if let sub = subtitle {
                            Text("(\(sub))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.moodletTextTertiary)
                        } else if let subscription = product.subscription {
                            Text(periodText(for: subscription))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color.moodletTextSecondary)
                        }
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.moodletPrimary : Color.moodletTextTertiary, lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color.moodletPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color.moodletPrimary.opacity(0.1) : Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func periodText(for subscription: Product.SubscriptionInfo) -> String {
        switch subscription.subscriptionPeriod.unit {
        case .month: return "/month"
        case .year: return "/year"
        default: return ""
        }
    }
}

// MARK: - Onboarding Premium Upsell
struct OnboardingPremiumUpsell: View {
    private var storeManager = StoreKitManager.shared
    @State private var selectedProductId: String?
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    let onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.moodletPrimary, .moodletAccent],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("Unlock Premium")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.moodletTextPrimary)

                Text("Get the most out of your Moodlet journey")
                    .font(.subheadline)
                    .foregroundStyle(Color.moodletTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Features
            VStack(alignment: .leading, spacing: 10) {
                premiumFeature(icon: "pawprint.fill", text: "All 6 Moodlet species")
                premiumFeature(icon: "tshirt.fill", text: "100+ exclusive accessories")
                premiumFeature(icon: "sparkles", text: "Seasonal exclusive items")
                premiumFeature(icon: "chart.xyaxis.line", text: "Advanced insights")
            }
            .padding()
            .background(Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))

            Spacer()

            // Plans
            VStack(spacing: 10) {
                if let yearly = storeManager.yearlyProduct {
                    CompactPlanButton(
                        title: "Yearly",
                        price: yearly.displayPrice,
                        badge: "Save 50%",
                        isSelected: selectedProductId == yearly.id
                    ) {
                        selectedProductId = yearly.id
                    }
                }

                if let monthly = storeManager.monthlyProduct {
                    CompactPlanButton(
                        title: "Monthly",
                        price: monthly.displayPrice,
                        badge: nil,
                        isSelected: selectedProductId == monthly.id
                    ) {
                        selectedProductId = monthly.id
                    }
                }
            }

            // Subscribe Button
            Button {
                if let productId = selectedProductId,
                   let product = storeManager.products.first(where: { $0.id == productId }) {
                    Task {
                        isPurchasing = true
                        do {
                            _ = try await storeManager.purchase(product)
                            isPurchasing = false
                            onComplete()
                        } catch StoreError.userCancelled {
                            isPurchasing = false
                        } catch {
                            isPurchasing = false
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Start Premium")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.moodletPrimary, .moodletAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.cornerRadius))
            }
            .disabled(selectedProductId == nil || isPurchasing)

            // Skip Button
            Button("Maybe Later") {
                onComplete()
            }
            .font(.subheadline)
            .foregroundStyle(Color.moodletTextSecondary)

            // Legal
            Text("Cancel anytime. Terms apply.")
                .font(.caption2)
                .foregroundStyle(Color.moodletTextTertiary)
        }
        .padding()
        .onAppear {
            if let yearly = storeManager.yearlyProduct {
                selectedProductId = yearly.id
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func premiumFeature(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.moodletPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.moodletTextPrimary)
        }
    }
}

// MARK: - Compact Plan Button
struct CompactPlanButton: View {
    let title: String
    let price: String
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.moodletTextPrimary)

                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.moodletAccent)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(price)
                    .foregroundStyle(Color.moodletTextSecondary)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.moodletPrimary : Color.moodletTextTertiary)
            }
            .padding()
            .background(isSelected ? Color.moodletPrimary.opacity(0.1) : Color.moodletSurface)
            .clipShape(RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: MoodletTheme.smallCornerRadius)
                    .stroke(isSelected ? Color.moodletPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extension
extension View {
    func premiumGated(featureName: String, requiresPremium: Bool = true) -> some View {
        modifier(PremiumGatedModifier(featureName: featureName, requiresPremium: requiresPremium))
    }
}

// MARK: - Preview
#Preview("Upgrade Sheet") {
    UpgradeSheet()
}

#Preview("Onboarding Upsell") {
    OnboardingPremiumUpsell(onComplete: {})
        .background(Color.moodletBackground)
}
