import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        Text("BloomCanvas")
                            .font(.largeTitle.weight(.bold))
                        
                        Text("Mini iPad coloring book for iPhone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Looking for logos section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Looking for creative logos & projects", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(.purple)
                            
                            Text("Ai2Life Technologies is actively seeking beautiful logos, brand marks, and exciting project ideas. Whether it’s a clever mark, a full identity, or just a spark of inspiration — we’d love to hear from you.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Link(destination: URL(string: "https://ai2life.org")!) {
                                HStack {
                                    Text("Visit ai2life.org")
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.subheadline.weight(.semibold))
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // How it works
                    GroupBox("How it works") {
                        VStack(alignment: .leading, spacing: 10) {
                            step(number: "1", text: "Import any photo from your library")
                            step(number: "2", text: "We instantly turn it into clean line art")
                            step(number: "3", text: "Color freely with PencilKit tools")
                            step(number: "4", text: "Export, share, or keep blooming")
                        }
                    }
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Built with ❤️ in the Lehigh Valley")
                            .font(.subheadline)
                        Text("by Ai2Life Technologies")
                            .font(.subheadline.weight(.medium))
                        Text("Useful apps & practical AI systems for real-world work.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func step(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(.purple))
            
            Text(text)
                .font(.subheadline)
        }
    }
}
