import SwiftUI
import PencilKit
import Photos

struct ColoringView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: StoreManager
    @EnvironmentObject var persistence: DrawingPersistence
    
    @State var project: CanvasProject
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showShare = false
    @State private var exportedImage: UIImage?
    @State private var showSaveSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                // The canvas experience
                CanvasRepresentable(
                    canvasView: $canvasView,
                    toolPicker: $toolPicker,
                    outlineImage: project.outlineImage
                )
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle(project.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        saveDrawing()
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        canvasView.undoManager?.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    
                    Button {
                        canvasView.undoManager?.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    
                    Button {
                        exportAndShare()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                if let img = exportedImage {
                    ShareSheet(items: [img])
                }
            }
            .alert("Saved!", isPresented: $showSaveSuccess) {
                Button("OK") { }
            } message: {
                Text("Your canvas was saved to Photos.")
            }
            .onAppear {
                // Restore previous drawing if any
                if let data = project.drawingData,
                   let drawing = try? PKDrawing(data: data) {
                    canvasView.drawing = drawing
                }
                
                // Present tool picker
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    toolPicker.addObserver(canvasView)
                    canvasView.becomeFirstResponder()
                }
            }
        }
    }
    
    private func saveDrawing() {
        project.drawingData = canvasView.drawing.dataRepresentation()
        
        // Update thumbnail with colored version
        if let composite = compositeImage() {
            project.thumbnailData = composite.jpegData(compressionQuality: 0.7)
        }
        
        persistence.update(project)
    }
    
    private func exportAndShare() {
        guard let composite = compositeImage() else { return }
        
        // Optional watermark for free users
        let final: UIImage
        if store.isLifetimeUnlocked {
            final = composite
        } else {
            final = addWatermark(to: composite)
        }
        
        exportedImage = final
        showShare = true
        
        // Also offer to save to Photos
        UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil)
        showSaveSuccess = true
    }
    
    private func compositeImage() -> UIImage? {
        guard let outline = project.outlineImage else { return nil }
        
        let drawingImage = canvasView.drawing.image(
            from: canvasView.bounds,
            scale: UIScreen.main.scale
        )
        
        let size = outline.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            // Draw outline first
            outline.draw(in: CGRect(origin: .zero, size: size))
            // Then the colored strokes on top
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func addWatermark(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            
            let text = "BloomCanvas • Unlock Lifetime $1.99"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let size = text.size(withAttributes: attrs)
            let point = CGPoint(x: image.size.width - size.width - 16,
                                y: image.size.height - size.height - 16)
            
            // Soft background
            let bg = CGRect(x: point.x - 8, y: point.y - 4, width: size.width + 16, height: size.height + 8)
            UIColor.black.withAlphaComponent(0.35).setFill()
            UIBezierPath(roundedRect: bg, cornerRadius: 6).fill()
            
            text.draw(at: point, withAttributes: attrs)
        }
    }
}

// MARK: - PencilKit Representable

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    var outlineImage: UIImage?
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        
        // Background image view (the line art)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = outlineImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = 100
        
        // Canvas on top
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isScrollEnabled = false   // we can add scroll later if needed
        
        container.addSubview(imageView)
        container.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            canvasView.topAnchor.constraint(equalTo: container.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.viewWithTag(100) as? UIImageView {
            imageView.image = outlineImage
        }
        canvasView.tool = toolPicker.selectedTool
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
