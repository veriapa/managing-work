import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: GenerateIcon.swift <iconset-directory>\n", stderr)
    exit(EXIT_FAILURE)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let iconSizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, size) in iconSizes {
    let scale = size / 1024
    func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
        NSPoint(x: x, y: y)
    }

    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fputs("Could not create icon bitmap at \(Int(size))px\n", stderr)
        exit(EXIT_FAILURE)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    context.cgContext.scaleBy(x: scale, y: scale)

    NSColor.black.setFill()
    NSBezierPath(
        roundedRect: NSRect(x: 0, y: 0, width: 1024, height: 1024),
        xRadius: 225,
        yRadius: 225
    ).fill()

    let face = NSBezierPath(ovalIn: NSRect(x: 142, y: 112, width: 740, height: 740))
    face.lineWidth = 28
    NSColor.white.setStroke()
    face.stroke()

    let crown = NSBezierPath(
        roundedRect: NSRect(x: 464, y: 838, width: 96, height: 82),
        xRadius: 18,
        yRadius: 18
    )
    NSColor.white.setFill()
    crown.fill()

    let crownCap = NSBezierPath(
        roundedRect: NSRect(x: 432, y: 894, width: 160, height: 34),
        xRadius: 15,
        yRadius: 15
    )
    crownCap.fill()

    let center = point(512, 482)
    let minuteHand = NSBezierPath()
    minuteHand.move(to: center)
    minuteHand.line(to: point(512, 694))
    minuteHand.lineWidth = 34
    minuteHand.lineCapStyle = .round
    minuteHand.stroke()

    let hourHand = NSBezierPath()
    hourHand.move(to: center)
    hourHand.line(to: point(664, 394))
    hourHand.lineWidth = 34
    hourHand.lineCapStyle = .round
    hourHand.stroke()

    let pivot = NSBezierPath(ovalIn: NSRect(x: 485, y: 455, width: 54, height: 54))
    pivot.fill()

    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fputs("Could not encode icon at \(Int(size))px\n", stderr)
        exit(EXIT_FAILURE)
    }

    try png.write(to: outputDirectory.appendingPathComponent(filename))
}
