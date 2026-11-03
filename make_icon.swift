// 시계 모양 앱 아이콘(AppIcon.icns)을 생성한다.
// 사용: swift make_icon.swift  (iconutil 필요)
import AppKit

func render(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // 배경: macOS 아이콘 그리드에 맞춘 둥근 사각형
    let inset = s * 0.1
    let bg = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    ctx.addPath(CGPath(roundedRect: bg, cornerWidth: bg.width * 0.225, cornerHeight: bg.width * 0.225, transform: nil))
    ctx.setFillColor(NSColor(white: 0.08, alpha: 1).cgColor)
    ctx.fillPath()

    // 시계판
    let c = CGPoint(x: s / 2, y: s / 2)
    let r = bg.width * 0.36
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(s * 0.03)
    ctx.strokeEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))

    // 눈금 12개
    ctx.setLineCap(.round)
    for i in 0..<12 {
        let a = CGFloat(i) * .pi / 6
        let len = i % 3 == 0 ? r * 0.18 : r * 0.09
        ctx.setLineWidth(i % 3 == 0 ? s * 0.022 : s * 0.012)
        ctx.move(to: CGPoint(x: c.x + sin(a) * (r * 0.86), y: c.y + cos(a) * (r * 0.86)))
        ctx.addLine(to: CGPoint(x: c.x + sin(a) * (r * 0.86 - len), y: c.y + cos(a) * (r * 0.86 - len)))
        ctx.strokePath()
    }

    // 바늘: 10시 10분
    func hand(_ angle: CGFloat, _ length: CGFloat, _ width: CGFloat, _ color: NSColor) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(width)
        ctx.move(to: c)
        ctx.addLine(to: CGPoint(x: c.x + sin(angle) * length, y: c.y + cos(angle) * length))
        ctx.strokePath()
    }
    hand(-.pi / 3 + (.pi / 36), r * 0.5, s * 0.04, .white)   // 시침
    hand(.pi / 3, r * 0.72, s * 0.028, .white)               // 분침
    hand(.pi * 0.85, r * 0.75, s * 0.012, .systemOrange)     // 초침

    ctx.setFillColor(NSColor.systemOrange.cgColor)
    let d = s * 0.035
    ctx.fillEllipse(in: CGRect(x: c.x - d, y: c.y - d, width: d * 2, height: d * 2))

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let fm = FileManager.default
let set = "AppIcon.iconset"
try? fm.removeItem(atPath: set)
try! fm.createDirectory(atPath: set, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    try! render(base).write(to: URL(fileURLWithPath: "\(set)/icon_\(base)x\(base).png"))
    try! render(base * 2).write(to: URL(fileURLWithPath: "\(set)/icon_\(base)x\(base)@2x.png"))
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", set, "-o", "AppIcon.icns"]
try! p.run(); p.waitUntilExit()
try? fm.removeItem(atPath: set)
print("AppIcon.icns 생성 완료")
