import Foundation
import SwiftUI

/// Manages recurring weekly scheduled goals and past history tracking.
public class ScheduleManager: ObservableObject {
    public static let shared = ScheduleManager()
    
    private let storage: LocalStorage
    
    @Published public var scheduledGoals: [ScheduledGoal] = [] {
        didSet {
            storage.saveSchedule(scheduledGoals)
        }
    }
    
    @Published public var historyLogs: [DailyLog] = [] {
        didSet {
            storage.saveHistory(historyLogs)
        }
    }
    
    public init(storage: LocalStorage = .shared) {
        self.storage = storage
        self.scheduledGoals = storage.loadSchedule()
        self.historyLogs = storage.loadHistory()
        
        // Seed default sample scheduled goal if empty
        if scheduledGoals.isEmpty {
            // Monday (2) and Wednesday (4) and Friday (6) sample schedule
            let defaultGoals = [
                ScheduledGoal(timerId: UUID(), dayOfWeek: 2, isRecurring: true, reminderEnabled: true),
                ScheduledGoal(timerId: UUID(), dayOfWeek: 4, isRecurring: true, reminderEnabled: true)
            ]
            self.scheduledGoals = defaultGoals
            self.storage.saveSchedule(defaultGoals)
        }
    }
    
    // MARK: - Goal Management
    
    public func addGoals(for timerId: UUID, daysOfWeek: Set<Int>, isRecurring: Bool) {
        for day in daysOfWeek {
            // Avoid duplicate goal for the same day and timer
            if !scheduledGoals.contains(where: { $0.timerId == timerId && $0.dayOfWeek == day }) {
                let goal = ScheduledGoal(
                    id: UUID(),
                    timerId: timerId,
                    dayOfWeek: day,
                    isRecurring: isRecurring,
                    reminderEnabled: true
                )
                scheduledGoals.append(goal)
            }
        }
    }
    
    public func removeGoal(id: UUID) {
        scheduledGoals.removeAll(where: { $0.id == id })
    }
    
    public func goalsForDay(_ dayOfWeek: Int) -> [ScheduledGoal] {
        return scheduledGoals.filter { $0.dayOfWeek == dayOfWeek }
    }
    
    // MARK: - Schedule Activation
    
    /// Checks today's weekday and ensures scheduled timers exist in TimerManager with a scheduled badge
    public func checkAndApplyScheduledTimers(timerManager: TimerManager) {
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        let todayGoals = goalsForDay(currentWeekday)

        for goal in todayGoals {
            if let index = timerManager.timers.firstIndex(where: { $0.id == goal.timerId }) {
                // Timer exists — just badge it as scheduled
                timerManager.timers[index].isScheduled = true
            } else {
                // Timer does not exist — look up from any historical timer in storage
                // or create a placeholder with the stored goal's timerId
                // Use a generic scheduled timer with the goal's timerId preserved
                let newTimer = TimerItem(
                    id: goal.timerId,
                    name: "Scheduled Goal",
                    emoji: "📅",
                    colorHex: "#4FC3F7",
                    dailyGoalSeconds: 3600,
                    elapsedSeconds: 0,
                    isRunning: false,
                    isScheduled: true
                )
                timerManager.addTimer(newTimer)
            }
        }
    }

    
    // MARK: - History Lookups
    
    public func logsForDate(_ date: Date) -> [DailyLog] {
        return historyLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    public func totalSecondsCompleted(on date: Date) -> Int {
        return logsForDate(date).reduce(0) { $0 + $1.secondsCompleted }
    }
    
    public func clearHistoryOlderThan(days: Int = 30) -> Int {
        let removed = storage.clearHistoryOlderThan(days: days)
        self.historyLogs = storage.loadHistory()
        return removed
    }
    
    public func reload() {
        self.scheduledGoals = storage.loadSchedule()
        self.historyLogs = storage.loadHistory()
    }
}

