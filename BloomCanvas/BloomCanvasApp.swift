import SwiftUI
import StoreKit

@main
struct BloomCanvasApp: App {
    @StateObject private var store = StoreManager()
    @StateObject private var persistence = DrawingPersistence()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(persistence)
                .task {
                    await store.loadProducts()
                    await store.updatePurchasedState()
                }
        }
    }
}
