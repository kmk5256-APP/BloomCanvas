import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: StoreManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Hero
                    VStack(spacing: 12) {
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .padding(.top, 12)
                        
                        Text("Unlock Lifetime Creativity")
                            .font(.title.weight(.bold))
                            .multilineTextAlignment(.center)
                        
                        Text("One payment. Forever yours.\nNo subscriptions. No limits.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Price card
                    VStack(spacing: 8) {
                        Text("$1.99")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.purple)
                        
                        Text("Lifetime Access")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.purple.opacity(0.25), lineWidth: 1.5)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 16) {
                        benefit(icon: "infinity", title: "Unlimited Photo Imports", subtitle: "Turn every memory into a canvas")
                        benefit(icon: "xmark.circle", title: "No Watermarks", subtitle: "Clean, shareable masterpieces")
                        benefit(icon: "sparkles", title: "Premium Feel Forever", subtitle: "Support indie creators & keep blooming")
                        benefit(icon: "heart.fill", title: "One-Time Love", subtitle: "No monthly fees. Ever.")
                    }
                    .padding(.horizontal, 24)
                    
                    // CTA
                    Button {
                        Task {
                            await store.purchaseLifetime()
                            if store.isLifetimeUnlocked {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if store.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Unlock Lifetime — $1.99")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .disabled(store.isPurchasing || store.products.isEmpty)
                    .padding(.horizontal)
                    
                    if let error = store.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Trust
                    VStack(spacing: 6) {
                        Text("Secure payment via App Store")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Cancel anytime in Settings → Apple ID → Subscriptions (though there’s nothing recurring 😉)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Maybe Later") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func benefit(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
