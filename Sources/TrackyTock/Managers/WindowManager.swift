import AppKit
import SwiftUI

/// Manages independent NSPanel windows for Add Timer and Settings.
/// Uses NSPanel (not NSWindow) with hidesOnDeactivate=false so windows stay
/// visible even when the MenuBarExtra .accessory app loses focus.
class WindowManager {
    static let shared = WindowManager()
    private var panels: [String: NSPanel] = [:]

    func open(id: String, title: String, width: CGFloat, height: CGFloat, view: NSView) {
        // Re-use existing panel if already open
        if let existing = panels[id] {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .hudWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = title
        panel.contentView = view
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false   // ← CRITICAL: keeps panel visible in .accessory mode
        panel.level = .floating           // ← stays above other windows
        panel.center()
        panel.isMovableByWindowBackground = true
        panels[id] = panel
        panel.makeKeyAndOrderFront(nil)
    }

    func close(id: String) {
        panels[id]?.orderOut(nil)
        panels.removeValue(forKey: id)
    }
}
