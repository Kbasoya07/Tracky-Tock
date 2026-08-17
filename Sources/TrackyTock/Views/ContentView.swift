import SwiftUI

/// Main popover window interface containing animated background, timers, calendar, themes, celebration overlays, and shortcuts.
public struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var quoteManager: QuoteManager
    @EnvironmentObject var localStorage: LocalStorage
    
    @State private var selectedTab: PopoverTab = .timers
    @State private var tabDirection: Int = 1   // +1 = slide right→left, -1 = slide left→right
    @State private var gradientShift: Bool = false
    @State private var showCelebrationOverlay: Bool = false

    @State private var isPlusHovered: Bool = false
    @State private var isSettingsHovered: Bool = false
    @State private var isQuitHovered: Bool = false
    
    enum PopoverTab: String, CaseIterable {
        case timers = "Timers"
        case calendar = "Calendar"
        case themes = "Themes"
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Subtle shifting background gradient (slow 10s loop)
            LinearGradient(
                colors: [
                    Color(hex: themeManager.currentTheme.backgroundColor).opacity(0.95),
                    Color(hex: themeManager.currentTheme.cardColor).opacity(gradientShift ? 0.90 : 0.70)
                ],
                startPoint: gradientShift ? .topLeading : .bottomLeading,
                endPoint: gradientShift ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
                    gradientShift.toggle()
                }
            }
            
            // Main Content Stack
            VStack(spacing: 0) {
                // Header Bar: ⏱️ icon + active badge + action buttons
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: themeManager.currentTheme.primaryColor))

                    if timerManager.runningTimersCount > 0 {
                        Text("\(timerManager.runningTimersCount) active")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green.opacity(0.2)))
                            .foregroundColor(.green)
                    }

                    Spacer()
                    
                    // Add Timer Button
                    Button(action: { openAddTimer() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(hex: themeManager.currentTheme.accentColor))
                            .scaleEffect(isPlusHovered ? 1.15 : 1.0)
                            .opacity(isPlusHovered ? 0.85 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onHover { isPlusHovered = $0 }
                    .help("Add New Timer (⌘N)")

                    // Settings Button
                    Button(action: { openSettings() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.body)
                            .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(isSettingsHovered ? 1.0 : 0.7))
                            .scaleEffect(isSettingsHovered ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onHover { isSettingsHovered = $0 }
                    .help("Settings & Preferences (⌘,)")
                    
                    // Quit App Button with Hover State
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "power")
                            .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(isQuitHovered ? 1.0 : 0.6))
                            .font(.body)
                            .scaleEffect(isQuitHovered ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onHover { isQuitHovered = $0 }
                    .help("Quit Tracky-Tock")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                
                // Tab Switcher (Timers vs Calendar vs Themes)
                Picker("Tab", selection: $selectedTab) {
                    Label("Timers", systemImage: "timer").tag(PopoverTab.timers)
                    Label("Calendar", systemImage: "calendar").tag(PopoverTab.calendar)
                    Label("Themes", systemImage: "paintpalette").tag(PopoverTab.themes)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
                .onChange(of: selectedTab) { newTab in
                    let tabs = PopoverTab.allCases
                    let oldIdx = tabs.firstIndex(of: selectedTab) ?? 0
                    let newIdx = tabs.firstIndex(of: newTab) ?? 0
                    tabDirection = newIdx >= oldIdx ? 1 : -1
                }
                
                Divider()
                
                // Daily Motivational Quote Banner — dynamic size and multiline support
                quoteBannerView
                
                Divider()
                
                // Content Body Based on Selected Tab
                Group {
                    if selectedTab == .timers {
                        timersListView
                            .transition(.asymmetric(
                                insertion: .move(edge: tabDirection > 0 ? .trailing : .leading).combined(with: .opacity),
                                removal:   .move(edge: tabDirection > 0 ? .leading  : .trailing).combined(with: .opacity)
                            ))
                    } else if selectedTab == .calendar {
                        CalendarView()
                            .environmentObject(timerManager)
                            .environmentObject(scheduleManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: tabDirection > 0 ? .trailing : .leading).combined(with: .opacity),
                                removal:   .move(edge: tabDirection > 0 ? .leading  : .trailing).combined(with: .opacity)
                            ))
                    } else {
                        ThemeSettingsView()
                            .environmentObject(themeManager)
                            .transition(.asymmetric(
                                insertion: .move(edge: tabDirection > 0 ? .trailing : .leading).combined(with: .opacity),
                                removal:   .move(edge: tabDirection > 0 ? .leading  : .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // Bottom Bar
                HStack {
                    Text("\(timerManager.timers.count) Timers • Space to Toggle")
                        .font(.caption2)
                        .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.6))
                    
                    Spacer()
                    
                    Button(action: { openAddTimer() }) {
                        Label("Add Timer", systemImage: "plus")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            
            // Completion Celebration Overlay & Confetti
            if showCelebrationOverlay, let completed = timerManager.celebratoryTimer {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ConfettiView()
                    
                    VStack(spacing: 8) {
                        Text("🎉")
                            .font(.system(size: 44))
                        Text("Goal Crushed!")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text("\(completed.emoji) \(completed.name)")
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Text("Daily target accomplished! Continuing in overtime...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: themeManager.currentTheme.cardColor).opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow, lineWidth: 2)
                            )
                            .shadow(color: Color.yellow.opacity(0.5), radius: 12)
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Hidden Keyboard Shortcut Triggers
            Group {
                // Space: Play/Pause active or first timer
                Button("") {
                    toggleActiveTimer()
                }
                .keyboardShortcut(.space, modifiers: [])
                .opacity(0)
                .frame(width: 0, height: 0)
                
                // Cmd + N: New timer
                Button("") { openAddTimer() }
                    .keyboardShortcut("n", modifiers: .command)
                    .opacity(0)
                    .frame(width: 0, height: 0)

                // Cmd + ,: Settings
                Button("") { openSettings() }
                    .keyboardShortcut(",", modifiers: .command)
                    .opacity(0)
                    .frame(width: 0, height: 0)
            }
        }
        .frame(width: 400, height: 520)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
        .onAppear {
            scheduleManager.checkAndApplyScheduledTimers(timerManager: timerManager)
        }
        .onChange(of: timerManager.celebratoryTimer) { timer in
            if timer != nil {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showCelebrationOverlay = true
                }
                // Auto-dismiss celebration overlay after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showCelebrationOverlay = false
                        timerManager.dismissCelebration()
                    }
                }
            }
        }
    }

    // MARK: - Quote Banner

    private var quoteFontSize: CGFloat {
        let length = quoteManager.currentQuote.count
        if length > 85 {
            return 9.5
        } else if length > 50 {
            return 10.5
        } else {
            return 11.5
        }
    }

    private var quoteBannerView: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\"\(quoteManager.currentQuote)\"")
                    .font(.system(size: quoteFontSize, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)

                Text("— \(quoteManager.author)")
                    .font(.system(size: max(8.5, quoteFontSize - 1.5), weight: .semibold))
                    .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.55))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 4)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    quoteManager.cycleNextQuote()
                }
            }) {
                Text("🔄")
                    .font(.system(size: 11))
                    .padding(4)
                    .background(Circle().fill(Color(hex: themeManager.currentTheme.textColor).opacity(0.06)))
            }
            .buttonStyle(.plain)
            .help("Show next motivational quote")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color(hex: themeManager.currentTheme.cardColor).opacity(0.35))
    }

    private func openAddTimer() {
        let tm = timerManager
        WindowManager.shared.open(
            id: "add-timer",
            title: "Create New Timer",
            width: 380, height: 440,
            view: NSHostingView(rootView:
                AddTimerView(onClose: { WindowManager.shared.close(id: "add-timer") })
                    .environmentObject(tm)
            )
        )
    }

    private func openSettings() {
        let tm = timerManager; let sm = scheduleManager
        let thm = themeManager; let ls = localStorage
        WindowManager.shared.open(
            id: "settings",
            title: "Settings & Preferences",
            width: 400, height: 520,
            view: NSHostingView(rootView:
                SettingsView(onClose: { WindowManager.shared.close(id: "settings") })
                    .environmentObject(tm)
                    .environmentObject(sm)
                    .environmentObject(thm)
                    .environmentObject(ls)
            )
        )
    }

    // MARK: - Timer List & Refined Empty State

    private var timersListView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 12) {
                if timerManager.timers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "timer")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: themeManager.currentTheme.accentColor).opacity(0.8))

                        Text("No timers yet. Create one!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: themeManager.currentTheme.textColor))

                        Text("Track multiple productivity timers with custom goals and animated progress.")
                            .font(.caption)
                            .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Button(action: { openAddTimer() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill").font(.title3)
                                Text("Create First Timer").font(.subheadline).fontWeight(.bold)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: themeManager.currentTheme.accentColor)))
                            .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                } else {
                    ForEach(timerManager.timers) { timer in
                        TimerCardView(timer: timer)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleActiveTimer() {
        if let running = timerManager.timers.first(where: { $0.isRunning }) {
            timerManager.pauseTimer(id: running.id)
        } else if let first = timerManager.timers.first {
            timerManager.startTimer(id: first.id)
        }
    }
}
