import Foundation
import UIKit

struct CanvasProject: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var createdAt: Date
    var isPremade: Bool
    var thumbnailData: Data?
    var outlineData: Data?          // the line-art background
    var drawingData: Data?          // PKDrawing archived
    
    init(id: UUID = UUID(),
         title: String,
         createdAt: Date = Date(),
         isPremade: Bool = false,
         thumbnailData: Data? = nil,
         outlineData: Data? = nil,
         drawingData: Data? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.isPremade = isPremade
        self.thumbnailData = thumbnailData
        self.outlineData = outlineData
        self.drawingData = drawingData
    }
    
    var outlineImage: UIImage? {
        guard let data = outlineData else { return nil }
        return UIImage(data: data)
    }
    
    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
}
