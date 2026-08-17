import Foundation
import UIKit
import PencilKit

@MainActor
class DrawingPersistence: ObservableObject {
    @Published var projects: [CanvasProject] = []
    
    private let fileManager = FileManager.default
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var projectsFile: URL {
        documentsURL.appendingPathComponent("bloom_projects.json")
    }
    
    init() {
        load()
        seedPremadeIfNeeded()
    }
    
    func load() {
        guard fileManager.fileExists(atPath: projectsFile.path) else {
            projects = []
            return
        }
        do {
            let data = try Data(contentsOf: projectsFile)
            projects = try JSONDecoder().decode([CanvasProject].self, from: data)
            projects.sort { $0.createdAt > $1.createdAt }
        } catch {
            print("Load error: \(error)")
            projects = []
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: projectsFile, options: .atomic)
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func add(_ project: CanvasProject) {
        projects.insert(project, at: 0)
        save()
    }
    
    func update(_ project: CanvasProject) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
            save()
        }
    }
    
    func delete(_ project: CanvasProject) {
        projects.removeAll { $0.id == project.id }
        save()
    }
    
    func userImportCount() -> Int {
        projects.filter { !$0.isPremade }.count
    }
    
    // MARK: - Premade starter pages (procedural simple outlines)
    
    private func seedPremadeIfNeeded() {
        guard projects.filter({ $0.isPremade }).isEmpty else { return }
        
        let premades = [
            makeSimpleFlower(),
            makeSimpleHeart(),
            makeSimpleStar(),
            makeSimpleMandala()
        ]
        
        for p in premades {
            projects.append(p)
        }
        save()
    }
    
    private func makeSimpleFlower() -> CanvasProject {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineWidth(6)
            cg.setLineCap(.round)
            
            // Center circle
            let center = CGPoint(x: 400, y: 400)
            cg.strokeEllipse(in: CGRect(x: 360, y: 360, width: 80, height: 80))
            
            // Petals
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * 120,
                    y: center.y + sin(angle) * 120
                )
                cg.strokeEllipse(in: CGRect(x: petalCenter.x - 50, y: petalCenter.y - 70, width: 100, height: 140))
            }
            
            // Stem
            cg.move(to: CGPoint(x: 400, y: 440))
            cg.addLine(to: CGPoint(x: 400, y: 720))
            cg.strokePath()
            
            // Leaves
            cg.strokeEllipse(in: CGRect(x: 320, y: 560, width: 80, height: 40))
            cg.strokeEllipse(in: CGRect(x: 400, y: 600, width: 80, height: 40))
        }
        
        return CanvasProject(
            title: "Simple Flower",
            isPremade: true,
            thumbnailData: image.jpegData(compressionQuality: 0.7),
            outlineData: image.pngData()
        )
    }
    
    private func makeSimpleHeart() -> CanvasProject {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineWidth(8)
            cg.setLineCap(.round)
            cg.setLineJoin(.round)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 400, y: 620))
            path.addCurve(to: CGPoint(x: 160, y: 320),
                          controlPoint1: CGPoint(x: 400, y: 520),
                          controlPoint2: CGPoint(x: 160, y: 480))
            path.addArc(withCenter: CGPoint(x: 250, y: 280),
                        radius: 110,
                        startAngle: .pi,
                        endAngle: 0,
                        clockwise: true)
            path.addArc(withCenter: CGPoint(x: 550, y: 280),
                        radius: 110,
                        startAngle: .pi,
                        endAngle: 0,
                        clockwise: true)
            path.addCurve(to: CGPoint(x: 400, y: 620),
                          controlPoint1: CGPoint(x: 640, y: 480),
                          controlPoint2: CGPoint(x: 400, y: 520))
            path.close()
            cg.addPath(path.cgPath)
            cg.strokePath()
        }
        
        return CanvasProject(
            title: "Big Heart",
            isPremade: true,
            thumbnailData: image.jpegData(compressionQuality: 0.7),
            outlineData: image.pngData()
        )
    }
    
    private func makeSimpleStar() -> CanvasProject {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineWidth(7)
            cg.setLineJoin(.round)
            
            let center = CGPoint(x: 400, y: 400)
            let outer: CGFloat = 220
            let inner: CGFloat = 90
            let points = 5
            
            let path = UIBezierPath()
            for i in 0..<points * 2 {
                let radius = (i % 2 == 0) ? outer : inner
                let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
                let pt = CGPoint(x: center.x + cos(angle) * radius,
                                 y: center.y + sin(angle) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.close()
            cg.addPath(path.cgPath)
            cg.strokePath()
        }
        
        return CanvasProject(
            title: "Star Power",
            isPremade: true,
            thumbnailData: image.jpegData(compressionQuality: 0.7),
            outlineData: image.pngData()
        )
    }
    
    private func makeSimpleMandala() -> CanvasProject {
        let size = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setLineWidth(4)
            
            let center = CGPoint(x: 400, y: 400)
            
            // Concentric circles
            for r in stride(from: 60, through: 280, by: 40) {
                cg.strokeEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r*2, height: r*2))
            }
            
            // Radial lines
            for i in 0..<12 {
                let angle = CGFloat(i) * .pi / 6
                cg.move(to: center)
                cg.addLine(to: CGPoint(x: center.x + cos(angle) * 280,
                                       y: center.y + sin(angle) * 280))
                cg.strokePath()
            }
            
            // Small petals around
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let p = CGPoint(x: center.x + cos(angle) * 180,
                                y: center.y + sin(angle) * 180)
                cg.strokeEllipse(in: CGRect(x: p.x - 25, y: p.y - 25, width: 50, height: 50))
            }
        }
        
        return CanvasProject(
            title: "Mini Mandala",
            isPremade: true,
            thumbnailData: image.jpegData(compressionQuality: 0.7),
            outlineData: image.pngData()
        )
    }
}
