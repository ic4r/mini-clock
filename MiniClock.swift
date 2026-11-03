import SwiftUI
import AppKit

@main
struct MiniClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ClockView()
                .frame(minWidth: 240, minHeight: 130)
        }
        .defaultSize(width: 440, height: 240)
        .windowStyle(.hiddenTitleBar)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            for w in NSApp.windows {
                w.backgroundColor = .black
                w.isMovableByWindowBackground = true
                w.level = .floating  // 항상 위에 표시
                w.collectionBehavior.insert(.fullScreenAuxiliary)
            }
        }
    }
}

struct ClockView: View {
    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "h:mm:ss"
        return f
    }()

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일, EEEE"
        return f
    }()

    var body: some View {
        GeometryReader { geo in
            // 창 크기에 맞춰 글자 크기를 비례 조정한다
            let size = min(geo.size.width / 4.2, geo.size.height / 2.2)
            TimelineView(.periodic(from: .now, by: 1)) { ctx in
                VStack(spacing: size * 0.02) {
                    Text(Self.timeFmt.string(from: ctx.date))
                        .font(.custom("Futura-Medium", size: size).monospacedDigit())
                    Text(Self.dateFmt.string(from: ctx.date))
                        .font(.system(size: size * 0.24, weight: .semibold))
                }
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
