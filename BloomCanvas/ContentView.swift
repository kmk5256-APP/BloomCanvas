import SwiftUI
import PhotosUI

struct ContentView: View {
    @EnvironmentObject var store: StoreManager
    @EnvironmentObject var persistence: DrawingPersistence
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPaywall = false
    @State private var showAbout = false
    @State private var showOnboarding = false
    @State private var isProcessing = false
    @State private var processingError: String?
    @State private var activeProject: CanvasProject?
    
    private var freeImportsLeft: Int {
        max(0, store.freeImportLimit - persistence.userImportCount())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Soft background
                LinearGradient(
                    colors: [Color(.systemBackground), Color.purple.opacity(0.05), Color.pink.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero / Advertise banner
                        advertiseBanner
                        
                        // Import section
                        importSection
                        
                        // Gallery
                        if !persistence.projects.isEmpty {
                            gallerySection
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("BloomCanvas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "sparkles")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if !store.isLifetimeUnlocked {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Unlock", systemImage: "lock.open.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    } else {
                        Label("Lifetime", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .fullScreenCover(item: $activeProject) { project in
                ColoringView(project: project)
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task { await handleImport(newItem) }
            }
            .alert("Processing Error", isPresented: .constant(processingError != nil)) {
                Button("OK") { processingError = nil }
            } message: {
                Text(processingError ?? "")
            }
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.35).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.4)
                                .tint(.white)
                            Text("Turning photo into canvas…")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(28)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") == false {
                    showOnboarding = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    showOnboarding = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var advertiseBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text("We're looking for creative logos & projects!")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            Text("Got a logo idea or fun project? Reach out at ai2life.org. Meanwhile — import a photo and bloom it into art.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var importSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Import Photo → Canvas")
                            .font(.headline)
                        if store.isLifetimeUnlocked {
                            Text("Unlimited • Lifetime unlocked")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Text("\(freeImportsLeft) free imports left")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
            .buttonStyle(.plain)
            .disabled(isProcessing)
            
            if !store.isLifetimeUnlocked && freeImportsLeft == 0 {
                Button {
                    showPaywall = true
                } label: {
                    Text("Unlock unlimited imports for $1.99")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            }
        }
    }
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Canvases")
                .font(.title2.weight(.bold))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                ForEach(persistence.projects) { project in
                    projectCard(project)
                }
            }
        }
    }
    
    private func projectCard(_ project: CanvasProject) -> some View {
        Button {
            activeProject = project
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    if let thumb = project.thumbnail {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.15)
                        Image(systemName: "paintbrush.pointed")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(project.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                
                HStack {
                    Text(project.isPremade ? "Premade" : project.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if project.isPremade {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if !project.isPremade {
                Button(role: .destructive) {
                    persistence.delete(project)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette")
                .font(.system(size: 56))
                .foregroundStyle(.purple.opacity(0.6))
            Text("Your first canvas awaits")
                .font(.title3.weight(.semibold))
            Text("Import any photo and watch it bloom into a colorable work of art.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Import logic
    
    private func handleImport(_ item: PhotosPickerItem) async {
        // Check free limit
        if !store.isLifetimeUnlocked && freeImportsLeft <= 0 {
            showPaywall = true
            selectedItem = nil
            return
        }
        
        isProcessing = true
        defer {
            isProcessing = false
            selectedItem = nil
        }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                processingError = "Could not load the photo."
                return
            }
            
            // Convert to line art
            guard let outline = PhotoToLineArt.convert(uiImage) else {
                processingError = "Failed to create line art. Try another photo."
                return
            }
            
            let project = CanvasProject(
                title: "Photo Canvas \(Date().formatted(date: .numeric, time: .shortened))",
                isPremade: false,
                thumbnailData: outline.jpegData(compressionQuality: 0.6),
                outlineData: outline.pngData()
            )
            
            persistence.add(project)
            activeProject = project
            
        } catch {
            processingError = error.localizedDescription
        }
    }
}
