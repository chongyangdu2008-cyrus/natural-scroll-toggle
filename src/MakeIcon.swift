import AppKit
import Foundation

let directory = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
let icons = [(16, "icon_16x16.png"), (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"), (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"), (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"), (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"), (1024, "icon_512x512@2x.png")]
for (size, name) in icons {
    let image = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: image)
    let scale = NSAffineTransform()
    scale.scale(by: CGFloat(size) / 1024)
    scale.concat()
    let tile = NSBezierPath(roundedRect: NSRect(x: 80, y: 80, width: 864, height: 864), xRadius: 192, yRadius: 192)
    NSColor.white.setFill()
    tile.fill()
    NSColor(srgbRed: 10 / 255, green: 132 / 255, blue: 1, alpha: 1).setStroke()
    let arrows = NSBezierPath()
    arrows.lineWidth = 65
    arrows.lineCapStyle = .round
    arrows.lineJoinStyle = .round
    arrows.move(to: NSPoint(x: 390, y: 310))
    arrows.line(to: NSPoint(x: 390, y: 716))
    arrows.move(to: NSPoint(x: 282, y: 607))
    arrows.line(to: NSPoint(x: 390, y: 716))
    arrows.line(to: NSPoint(x: 498, y: 607))
    arrows.move(to: NSPoint(x: 634, y: 714))
    arrows.line(to: NSPoint(x: 634, y: 308))
    arrows.move(to: NSPoint(x: 526, y: 417))
    arrows.line(to: NSPoint(x: 634, y: 308))
    arrows.line(to: NSPoint(x: 742, y: 417))
    arrows.stroke()
    NSGraphicsContext.restoreGraphicsState()
    try image.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(name))
}
