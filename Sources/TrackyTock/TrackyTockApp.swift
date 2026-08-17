import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Enforce accessory / agent mode (no Dock icon, menu bar only)
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct TrackyTockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var timerManager = TimerManager()
    @StateObject private var scheduleManager = ScheduleManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var quoteManager = QuoteManager()
    @StateObject private var localStorage = LocalStorage()

    @AppStorage("showTimerInMenuBar") private var showTimerInMenuBar: Bool = true
    @AppStorage("showProgressRingInMenuBar") private var showProgressRingInMenuBar: Bool = true
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(timerManager)
                .environmentObject(scheduleManager)
                .environmentObject(themeManager)
                .environmentObject(quoteManager)
                .environmentObject(localStorage)
        } label: {
            MenuBarView(
                timerManager: timerManager,
                themeManager: themeManager,
                showTimerInMenuBar: showTimerInMenuBar,
                showProgressRingInMenuBar: showProgressRingInMenuBar
            )
        }
        .menuBarExtraStyle(.window)
    }
}
