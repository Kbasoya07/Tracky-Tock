import Foundation
import SwiftUI
import Combine

/// Singleton timer engine supporting simultaneous timers, midnight reset, and goal celebration events.
public class TimerManager: ObservableObject {
    public static let shared = TimerManager()
    
    private let storage: LocalStorage
    private var cancellables = Set<AnyCancellable>()
    private var lastActiveDate: Date
    
    @Published public var timers: [TimerItem] = [] {
        didSet {
            storage.saveTimers(timers)
        }
    }
    
    /// Published event when a timer just reaches its daily goal for celebration triggers
    @Published public var celebratoryTimer: TimerItem? = nil
    
    public init(storage: LocalStorage = .shared) {
        self.storage = storage
        self.lastActiveDate = Date()
        
        // Load persisted timers
        let loaded = storage.loadTimers()
        if loaded.isEmpty {
            let defaultTimers = [
                TimerItem(name: "Studying", emoji: "📚", colorHex: "#FF6B6B", dailyGoalSeconds: 14400, elapsedSeconds: 3600, isRunning: false),
                TimerItem(name: "Deep Work", emoji: "💻", colorHex: "#4ECDC4", dailyGoalSeconds: 10800, elapsedSeconds: 1800, isRunning: false)
            ]
            self.timers = defaultTimers
            self.storage.saveTimers(defaultTimers)
        } else {
            self.timers = loaded
        }
        
        // Check for day boundary on launch
        checkMidnightReset()
        
        // Start single high-precision main runloop publisher
        setupTimerEngine()
    }
    
    // MARK: - Engine Setup
    
    private func setupTimerEngine() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
            .store(in: &cancellables)
    }
    
    /// Core tick logic executed every second
    public func tick() {
        checkMidnightReset()
        
        var updatedTimers = timers
        var justCompleted: TimerItem? = nil
        var hasChanges = false
        
        for index in updatedTimers.indices {
            if updatedTimers[index].isRunning {
                let prevElapsed = updatedTimers[index].elapsedSeconds
                let goal = updatedTimers[index].dailyGoalSeconds
                
                updatedTimers[index].elapsedSeconds += 1
                hasChanges = true
                
                // Detect exact moment when daily goal is reached
                if prevElapsed < goal && updatedTimers[index].elapsedSeconds >= goal {
                    justCompleted = updatedTimers[index]
                }
            }
        }
        
        if hasChanges {
            self.timers = updatedTimers
        }
        
        if let completed = justCompleted {
            triggerGoalCelebration(for: completed)
        }
    }
    
    // MARK: - Midnight Reset
    
    /// Checks if a new calendar day has started and resets timers accordingly
    public func checkMidnightReset() {
        let now = Date()
        if !Calendar.current.isDateInToday(lastActiveDate) {
            // Archive previous day's completed time to history logs
            var logs = storage.loadHistory()
            for timer in timers where timer.elapsedSeconds > 0 {
                let log = DailyLog(
                    id: UUID(),
                    date: lastActiveDate,
                    timerId: timer.id,
                    secondsCompleted: timer.elapsedSeconds
                )
                logs.append(log)
            }
            storage.saveHistory(logs)
            
            // Reset elapsed seconds for all timers
            for i in timers.indices {
                timers[i].elapsedSeconds = 0
            }
            
            lastActiveDate = now
        }
    }
    
    // MARK: - Celebrations
    
    private func triggerGoalCelebration(for timer: TimerItem) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            self.celebratoryTimer = timer
        }
    }
    
    public func dismissCelebration() {
        withAnimation {
            self.celebratoryTimer = nil
        }
    }
    
    // MARK: - Timer Control Actions
    
    public var activeTimer: TimerItem? {
        timers.first(where: { $0.isRunning })
    }
    
    public var runningTimersCount: Int {
        timers.filter { $0.isRunning }.count
    }
    
    /// Toggle running status without auto-pausing other timers
    public func toggleTimer(id: UUID) {
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].isRunning.toggle()
        }
    }
    
    public func startTimer(id: UUID) {
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].isRunning = true
        }
    }
    
    public func pauseTimer(id: UUID) {
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].isRunning = false
        }
    }
    
    public func resetTimer(id: UUID) {
        if let index = timers.firstIndex(where: { $0.id == id }) {
            timers[index].elapsedSeconds = 0
            timers[index].isRunning = false
        }
    }
    
    public func addTimer(_ timer: TimerItem) {
        timers.append(timer)
    }
    
    public func updateTimer(_ timer: TimerItem) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index] = timer
        }
    }
    
    public func deleteTimer(id: UUID) {
        timers.removeAll(where: { $0.id == id })
    }
    
    public func resetAllTimersForToday() {
        for i in timers.indices {
            timers[i].elapsedSeconds = 0
            timers[i].isRunning = false
        }
    }
    
    public func reloadTimers() {
        self.timers = storage.loadTimers()
    }
}

