import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let lifetimeProductID = "com.ai2life.bloomcanvas.lifetime"
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLifetimeUnlocked = false
    @Published var purchaseError: String?
    @Published var isPurchasing = false
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await handle(transaction)
                    await transaction.finish()
                }
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.lifetimeProductID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func updatePurchasedState() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.lifetimeProductID {
                isLifetimeUnlocked = true
                return
            }
        }
        isLifetimeUnlocked = false
    }
    
    func purchaseLifetime() async {
        guard let product = products.first(where: { $0.id == Self.lifetimeProductID }) else {
            purchaseError = "Product not available. Please try again later."
            return
        }
        
        isPurchasing = true
        purchaseError = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await handle(transaction)
                    await transaction.finish()
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        
        isPurchasing = false
    }
    
    private func handle(_ transaction: Transaction) async {
        if transaction.productID == Self.lifetimeProductID {
            isLifetimeUnlocked = true
        }
    }
    
    /// Free tier limit
    var freeImportLimit: Int { 3 }
}
