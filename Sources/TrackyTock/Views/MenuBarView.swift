import SwiftUI
import AppKit

/// Menu bar label with native NSImage circular progress ring, ticking HH:MM display, and real-time state observation.
public struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var themeManager: ThemeManager
    var showTimerInMenuBar: Bool
    var showProgressRingInMenuBar: Bool

    public init(
        timerManager: TimerManager,
        themeManager: ThemeManager,
        showTimerInMenuBar: Bool = true,
        showProgressRingInMenuBar: Bool = true
    ) {
        self.timerManager = timerManager
        self.themeManager = themeManager
        self.showTimerInMenuBar = showTimerInMenuBar
        self.showProgressRingInMenuBar = showProgressRingInMenuBar
    }

    private var runningTimers: [TimerItem] {
        timerManager.timers.filter { $0.isRunning }
    }

    private var activeProgress: Double {
        if runningTimers.count == 1, let t = runningTimers.first {
            return min(1.0, t.progress)
        } else if !runningTimers.isEmpty {
            let total = runningTimers.reduce(0.0) { $0 + $1.progress }
            return min(1.0, total / Double(runningTimers.count))
        } else if let first = timerManager.timers.first(where: { $0.elapsedSeconds > 0 }) {
            return min(1.0, first.progress)
        }
        return 0.0
    }

    private var isRunning: Bool {
        !runningTimers.isEmpty
    }

    /// Dynamically renders a crisp native NSImage containing the icon + circular progress ring
    private var iconImage: NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        let center = NSPoint(x: 9, y: 9)
        let radius: CGFloat = 7.5
        let accentNSColor = NSColor(Color(hex: themeManager.currentTheme.accentColor))

        if showProgressRingInMenuBar && isRunning {
            // Draw background track ring
            let track = NSBezierPath()
            track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
            track.lineWidth = 1.8
            accentNSColor.withAlphaComponent(0.25).setStroke()
            track.stroke()

            // Draw active progress arc (clockwise from top)
            if activeProgress > 0 {
                let arc = NSBezierPath()
                let startAngle: CGFloat = 90
                let sweep = CGFloat(min(1.0, max(0.03, activeProgress)) * 360)
                let endAngle: CGFloat = startAngle - sweep
                arc.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                arc.lineWidth = 1.8
                arc.lineCapStyle = .round
                accentNSColor.setStroke()
                arc.stroke()
            }
        }

        // Draw timer symbol in center
        if let symbol = NSImage(systemSymbolName: "timer", accessibilityDescription: nil) {
            let pointSize: CGFloat = (showProgressRingInMenuBar && isRunning) ? 8.5 : 12.0
            let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
            if let configured = symbol.withSymbolConfiguration(config) {
                let rect = NSRect(
                    x: (size.width - configured.size.width) / 2,
                    y: (size.height - configured.size.height) / 2,
                    width: configured.size.width,
                    height: configured.size.height
                )
                if showProgressRingInMenuBar && isRunning {
                    accentNSColor.set()
                }
                configured.draw(in: rect)
            }
        }

        image.unlockFocus()
        image.isTemplate = !(showProgressRingInMenuBar && isRunning)
        return image
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: iconImage)

            if showTimerInMenuBar, runningTimers.count == 1, let t = runningTimers.first {
                let hours = t.elapsedSeconds / 3600
                let minutes = (t.elapsedSeconds % 3600) / 60
                let isTick = (t.elapsedSeconds % 2 == 0)

                Text("\(t.emoji) \(String(format: "%02d", hours))\(isTick ? ":" : "·")\(String(format: "%02d", minutes))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
        }
        .fixedSize()
        .help("Tracky-Tock — Click to open")
    }
}
