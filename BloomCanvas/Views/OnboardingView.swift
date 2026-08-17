import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    
    @State private var page = 0
    
    var body: some View {
        TabView(selection: $page) {
            onboardingPage(
                icon: "photo.on.rectangle.angled",
                title: "Your photos become art",
                subtitle: "Import any picture. We instantly transform it into a clean, colorable line-art canvas.",
                color: .purple
            ).tag(0)
            
            onboardingPage(
                icon: "paintbrush.pointed.fill",
                title: "Color like on a mini iPad",
                subtitle: "Full PencilKit tools, zoom, undo, and a buttery smooth canvas experience designed for iPhone.",
                color: .pink
            ).tag(1)
            
            onboardingPage(
                icon: "sparkles",
                title: "We’re looking for creatives",
                subtitle: "Got a logo idea or cool project? Ai2Life would love to hear from you. Meanwhile — start blooming!",
                color: .orange
            ).tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            Button {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(page < 2 ? "Next" : "Start Coloring")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
    
    private func onboardingPage(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}
