import AppKit

let size = 1024
let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!
let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
graphics.imageInterpolation = .high

let canvas = CGRect(x: 0, y: 0, width: size, height: size)
NSColor.clear.setFill()
NSBezierPath(rect: canvas).fill()

let backgroundRect = CGRect(x: 34, y: 34, width: 956, height: 956)
let background = NSBezierPath(roundedRect: backgroundRect, xRadius: 218, yRadius: 218)
let backgroundGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.20, green: 0.35, blue: 0.92, alpha: 1),
    NSColor(calibratedRed: 0.42, green: 0.23, blue: 0.84, alpha: 1)
])!
backgroundGradient.draw(in: background, angle: -45)

let dialRect = CGRect(x: 190, y: 170, width: 644, height: 644)
let shadow = NSShadow()
shadow.shadowColor = NSColor(calibratedWhite: 0.08, alpha: 0.36)
shadow.shadowBlurRadius = 30
shadow.shadowOffset = NSSize(width: 0, height: -17)
shadow.set()
NSColor.white.setFill()
NSBezierPath(ovalIn: dialRect).fill()
NSShadow().set()

let center = CGPoint(x: dialRect.midX, y: dialRect.midY)
let radius: CGFloat = dialRect.width * 0.405
for index in 0..<60 {
    let angle = CGFloat(index) * .pi / 30 - .pi / 2
    let isHour = index.isMultiple(of: 5)
    let outer = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
    let innerRadius = radius - (isHour ? 29 : 14)
    let inner = CGPoint(x: center.x + cos(angle) * innerRadius, y: center.y + sin(angle) * innerRadius)
    let tick = NSBezierPath()
    tick.move(to: inner)
    tick.line(to: outer)
    tick.lineCapStyle = .round
    tick.lineWidth = isHour ? 9 : 4
    (isHour
        ? NSColor(calibratedRed: 0.20, green: 0.25, blue: 0.43, alpha: 1)
        : NSColor(calibratedRed: 0.59, green: 0.63, blue: 0.74, alpha: 1)).setStroke()
    tick.stroke()
}

func handPath(angle: CGFloat, length: CGFloat, width: CGFloat) -> NSBezierPath {
    let endpoint = CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
    let path = NSBezierPath()
    path.move(to: center)
    path.line(to: endpoint)
    path.lineCapStyle = .round
    path.lineWidth = width
    return path
}

NSColor(calibratedRed: 0.16, green: 0.21, blue: 0.37, alpha: 1).setStroke()
handPath(angle: .pi / 3, length: 190, width: 25).stroke()
NSColor(calibratedRed: 0.28, green: 0.39, blue: 0.93, alpha: 1).setStroke()
handPath(angle: .pi / 2, length: 250, width: 17).stroke()

NSColor(calibratedRed: 0.96, green: 0.39, blue: 0.33, alpha: 1).setStroke()
let secondHand = handPath(angle: -.pi / 3, length: 275, width: 8)
secondHand.stroke()

NSColor(calibratedRed: 0.96, green: 0.39, blue: 0.33, alpha: 1).setFill()
NSBezierPath(ovalIn: CGRect(x: center.x - 19, y: center.y - 19, width: 38, height: 38)).fill()
NSColor.white.setFill()
NSBezierPath(ovalIn: CGRect(x: center.x - 7, y: center.y - 7, width: 14, height: 14)).fill()

let crown = NSBezierPath(roundedRect: CGRect(x: 456, y: 833, width: 112, height: 80), xRadius: 28, yRadius: 28)
NSColor(calibratedRed: 0.95, green: 0.72, blue: 0.35, alpha: 1).setFill()
crown.fill()
NSColor(calibratedRed: 0.78, green: 0.51, blue: 0.19, alpha: 1).setStroke()
crown.lineWidth = 6
crown.stroke()

NSGraphicsContext.restoreGraphicsState()
guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("No se pudo crear el icono del reloj")
}
try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .atomic)
