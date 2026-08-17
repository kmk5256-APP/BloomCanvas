import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum PhotoToLineArt {
    
    /// Converts a photo into a clean black-line coloring page suitable as a canvas background.
    static func convert(_ image: UIImage, intensity: Float = 1.0) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        
        // 1. Make it grayscale for cleaner edges
        let grayscale = ciImage.applyingFilter("CIPhotoEffectMono")
        
        // 2. Enhance edges
        let edges = grayscale.applyingFilter("CIEdges", parameters: [
            kCIInputIntensityKey: intensity * 2.5
        ])
        
        // 3. Invert so lines are black on white (classic coloring book look)
        let inverted = edges.applyingFilter("CIColorInvert")
        
        // 4. Boost contrast and clean up noise
        let contrast = inverted.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: 1.8,
            kCIInputBrightnessKey: 0.05,
            kCIInputSaturationKey: 0.0
        ])
        
        // 5. Optional mild blur then unsharp to smooth jagged edges
        let blurred = contrast.applyingFilter("CIGaussianBlur", parameters: [
            kCIInputRadiusKey: 0.6
        ])
        
        let sharpened = blurred.applyingFilter("CIUnsharpMask", parameters: [
            kCIInputRadiusKey: 1.5,
            kCIInputIntensityKey: 0.6
        ])
        
        // Render
        guard let cgImage = context.createCGImage(sharpened, from: sharpened.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// Quick preview version (lighter processing)
    static func quickPreview(_ image: UIImage) -> UIImage? {
        convert(image, intensity: 0.8)
    }
}
