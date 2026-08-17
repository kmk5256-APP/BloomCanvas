# BloomCanvas 🎨

**Turn any photo into a beautiful colorable canvas — the mini iPad coloring book experience on your iPhone.**

BloomCanvas lets you import photos (or use premade pages), instantly convert them into clean line-art outlines, then color freely with PencilKit tools. Zoom, pan, undo, export, and share your masterpieces.

**Lifetime unlock: just $1.99** — no subscriptions, forever yours.

> ✨ **We're looking for creative logos and exciting projects!**  
> Got a logo idea, branding concept, or fun collaboration? Reach out while you color. Built with love by [Ai2Life Technologies](https://ai2life.org).

---

## Features

- **Photo → Line Art** in one tap (Core Image edge detection + smart processing)
- **PencilKit** drawing: pens, markers, erasers, colors — finger or Apple Pencil friendly
- **Zoom & pan** like a real mini-iPad canvas
- **Gallery** of your creations + premade starter pages
- **Unlimited imports** after lifetime unlock
- **Export** high-res PNG (outline + your colors composited)
- **Share** to Messages, Instagram, etc.
- **Beautiful modern UI** with dark mode support
- **One-time $1.99 lifetime** — alluring paywall designed for high conversion
- Soft onboarding + in-app call for creative logos/projects

## Setup in Xcode (2 minutes)

1. Open Xcode → **File → New → Project → iOS → App**
2. Product Name: `BloomCanvas`
3. Interface: **SwiftUI**, Language: **Swift**
4. Delete the default `ContentView.swift` and `BloomCanvasApp.swift`
5. Copy all files from this repo into your project (keep the group structure or flatten)
6. In **Signing & Capabilities**:
   - Add **In-App Purchase**
   - Add **Photo Library** (Privacy - Photo Library Usage Description: "BloomCanvas needs photos to turn into coloring canvases")
   - Camera if desired
7. In **App Store Connect** (later): create non-consumable IAP  
   Product ID: `com.ai2life.bloomcanvas.lifetime`  
   Price: $1.99  
   Display Name: Lifetime Unlock
8. Build & run on device or simulator (iOS 17+)

> Tip: For testing IAP in sandbox, use a Sandbox Apple ID.

## Project Structure

```
BloomCanvas/
├── BloomCanvasApp.swift          # App entry + StoreKit observer
├── ContentView.swift             # Main gallery + navigation
├── Models/
│   └── CanvasProject.swift
├── Services/
│   ├── PhotoToLineArt.swift      # Core Image photo → outline
│   ├── StoreManager.swift        # StoreKit 2 lifetime purchase
│   └── DrawingPersistence.swift  # Save/load user canvases
├── Views/
│   ├── ColoringView.swift        # Full PencilKit canvas experience
│   ├── PaywallView.swift         # Alluring $1.99 lifetime screen
│   ├── AboutView.swift           # Looking for logos & projects
│   └── OnboardingView.swift
└── README.md
```

## How Photo-to-Canvas Works

1. User picks photo via PhotosPicker
2. `PhotoToLineArt` applies:
   - Grayscale conversion
   - CIEdges / edge enhancement
   - Contrast & threshold for clean black lines on white
3. Result becomes the non-editable background of a `PKCanvasView`
4. User colors on top with full PencilKit tool picker
5. On save: composite background + drawing into one PNG

## Monetization (Conversion-Focused)

- Free: 3 photo imports + all premade pages + light watermark on export
- **Lifetime $1.99**: unlimited imports, no watermark, priority support feel, exclusive “Creator” badge vibe
- Paywall copy is intentionally warm, value-first, and scarcity-light (“one-time, forever”)

## Seeking Creative Partners

In the About screen and home banner:

> “Ai2Life Technologies is actively looking for creative logos, brand marks, and fun project ideas. If you have something cool, drop us a line at ai2life.org — while you’re here, bloom a few photos into art!”

## Tech Stack

- SwiftUI + PencilKit
- StoreKit 2
- Core Image
- PhotosUI
- FileManager for local persistence
- iOS 17+

---

Made with ❤️ in the Lehigh Valley by Ai2Life Technologies  
https://ai2life.org

**License**: Source available for learning & your own App Store submission. Keep the spirit of independent creators.
