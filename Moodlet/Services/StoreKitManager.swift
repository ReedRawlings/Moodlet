//
//  StoreKitManager.swift
//  Moodlet
//
//  StoreKit 2 integration for subscription and purchase management
//

import Foundation
import StoreKit

// MARK: - Product Identifiers
enum StoreProduct: String, CaseIterable {
    case premiumMonthly = "com.moodlet.premium.monthly"
    case premiumYearly = "com.moodlet.premium.yearly"

    var displayName: String {
        switch self {
        case .premiumMonthly: return "Monthly"
        case .premiumYearly: return "Yearly"
        }
    }
}

// MARK: - Store Error
enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    case userCancelled
    case pending
    case unknown

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: Equatable {
    case notSubscribed
    case subscribed(expirationDate: Date?, productId: String)
    case expired
    case inGracePeriod(expirationDate: Date)
    case inBillingRetry

    var isActive: Bool {
        switch self {
        case .subscribed, .inGracePeriod, .inBillingRetry:
            return true
        case .notSubscribed, .expired:
            return false
        }
    }
}

// MARK: - StoreKit Manager
@MainActor
@Observable
class StoreKitManager {
    // MARK: - Properties
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed
    private(set) var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private let productIds = StoreProduct.allCases.map { $0.rawValue }

    // MARK: - Singleton
    static let shared = StoreKitManager()

    // MARK: - Initialization
    init() {
        // Start listening for transactions
        updateListenerTask = listenForTransactions()

        // Load products and check subscription status
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let storeProducts = try await Product.products(for: productIds)
            // Sort products: monthly, yearly, lifetime
            products = storeProducts.sorted { product1, product2 in
                let order: [String: Int] = [
                    "monthly": 0,
                    "yearly": 1,
                    "lifetime": 2
                ]
                let order1 = order.first { product1.id.contains($0.key) }?.value ?? 3
                let order2 = order.first { product2.id.contains($0.key) }?.value ?? 3
                return order1 < order2
            }
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update subscription status
                await updateSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()

                isLoading = false
                return transaction

            case .userCancelled:
                isLoading = false
                throw StoreError.userCancelled

            case .pending:
                isLoading = false
                throw StoreError.pending

            @unknown default:
                isLoading = false
                throw StoreError.unknown
            }
        } catch StoreError.userCancelled {
            throw StoreError.userCancelled
        } catch StoreError.pending {
            throw StoreError.pending
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw StoreError.purchaseFailed
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Subscription Status
    func updateSubscriptionStatus() async {
        var foundActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            // Check for active subscription
            if transaction.productType == .autoRenewable {
                if let expirationDate = transaction.expirationDate {
                    if expirationDate > Date() {
                        purchasedProductIDs.insert(transaction.productID)
                        subscriptionStatus = .subscribed(
                            expirationDate: expirationDate,
                            productId: transaction.productID
                        )
                        foundActiveSubscription = true
                    }
                }
            }
        }

        if !foundActiveSubscription {
            purchasedProductIDs.removeAll()
            subscriptionStatus = .notSubscribed
        }

        // Save subscription state
        UserDefaults.standard.set(subscriptionStatus.isActive, forKey: "isPremiumUser")
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                do {
                    let transaction = try await self.checkVerified(result)

                    // Update subscription status on main actor
                    await self.updateSubscriptionStatus()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }

    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helper Methods
    func product(for identifier: StoreProduct) -> Product? {
        products.first { $0.id == identifier.rawValue }
    }

    var monthlyProduct: Product? {
        product(for: .premiumMonthly)
    }

    var yearlyProduct: Product? {
        product(for: .premiumYearly)
    }

    var isPremium: Bool {
        subscriptionStatus.isActive
    }

    // MARK: - Price Formatting
    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }

    func formattedPricePerMonth(for product: Product) -> String? {
        guard product.id.contains("yearly") else { return nil }

        let yearlyPrice = product.price
        let monthlyPrice = yearlyPrice / 12

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale

        return formatter.string(from: monthlyPrice as NSNumber)
    }

    func savingsPercentage(yearly: Product, monthly: Product) -> Int {
        let yearlyTotal = yearly.price
        let monthlyTotal = monthly.price * 12
        let savings = (monthlyTotal - yearlyTotal) / monthlyTotal * 100
        return Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
    }
}

// MARK: - Subscription Info Extension
extension StoreKitManager {
    var subscriptionExpirationDate: Date? {
        switch subscriptionStatus {
        case .subscribed(let date, _):
            return date
        case .inGracePeriod(let date):
            return date
        default:
            return nil
        }
    }

    var currentSubscriptionProductId: String? {
        switch subscriptionStatus {
        case .subscribed(_, let productId):
            return productId
        default:
            return nil
        }
    }

    func formattedExpirationDate() -> String? {
        guard let date = subscriptionExpirationDate else { return nil }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var statusDescription: String {
        switch subscriptionStatus {
        case .notSubscribed:
            return "Not subscribed"
        case .subscribed(_, let productId):
            if productId.contains("monthly") {
                return "Premium Monthly"
            } else {
                return "Premium Yearly"
            }
        case .expired:
            return "Subscription expired"
        case .inGracePeriod:
            return "Grace period"
        case .inBillingRetry:
            return "Billing retry"
        }
    }
}
