import AppKit

// Code-drawn identity asset; no network access or upstream application logo.
let repository = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let output = repository.appending(path: "ClipNest/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for file in try FileManager.default.contentsOfDirectory(at: output, includingPropertiesForKeys: nil)
where file.pathExtension == "png" {
  try FileManager.default.removeItem(at: file)
}
var images: [[String: String]] = []
for pointSize in [16, 32, 128, 256, 512] {
  for scale in [1, 2] {
    let pixels = pointSize * scale
    let bitmap = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
      isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current!.cgContext.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    NSColor(red: 0.06, green: 0.35, blue: 0.35, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896), xRadius: 208, yRadius: 208).fill()
    NSColor(red: 0.95, green: 0.97, blue: 0.91, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 284, y: 196, width: 456, height: 612), xRadius: 56, yRadius: 56).fill()
    NSColor(red: 0.39, green: 0.74, blue: 0.57, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 396, y: 742, width: 232, height: 106), xRadius: 32, yRadius: 32).fill()
    NSColor(red: 0.06, green: 0.35, blue: 0.35, alpha: 1).setFill()
    for (y, width) in [(600.0, 276.0), (488.0, 276.0), (376.0, 184.0)] {
      NSBezierPath(roundedRect: NSRect(x: 374, y: y, width: width, height: 36), xRadius: 18, yRadius: 18).fill()
    }
    NSGraphicsContext.restoreGraphicsState()
    let filename = "icon_\(pointSize)x\(pointSize)@\(scale)x.png"
    try bitmap.representation(using: .png, properties: [:])!.write(to: output.appending(path: filename))
    images.append(["filename": filename, "idiom": "mac", "scale": "\(scale)x", "size": "\(pointSize)x\(pointSize)"])
  }
}
let contents: [String: Any] = ["images": images, "info": ["author": "Cyprusky", "version": 1]]
try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
  .write(to: output.appending(path: "Contents.json"))
