import SwiftUI

/// Weekly calendar view with day selection, recurring goal scheduling, and past 7 days history tracking.
public struct CalendarView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var scheduleManager: ScheduleManager
    
    @State private var selectedDayOfWeek: Int = Calendar.current.component(.weekday, from: Date())
    @State private var viewMode: CalendarTab = .schedule
    @State private var selectedHistoryDate: Date = Date()
    
    enum CalendarTab: String, CaseIterable {
        case schedule = "Weekly Schedule"
        case history = "7-Day History"
    }
    
    // Weekday representations (Monday first in display, with calendar component mapping: Sun=1, Mon=2..Sat=7)
    private let weekDays: [(name: String, short: String, comp: Int)] = [
        ("Mon", "M", 2),
        ("Tue", "T", 3),
        ("Wed", "W", 4),
        ("Thu", "T", 5),
        ("Fri", "F", 6),
        ("Sat", "S", 7),
        ("Sun", "S", 1)
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Segmented Picker (Schedule vs History)
            Picker("Mode", selection: $viewMode) {
                ForEach(CalendarTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            if viewMode == .schedule {
                scheduleSection
            } else {
                historySection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(spacing: 12) {
            // 7-Day Horizontal Strip (Mon-Sun)
            HStack(spacing: 6) {
                ForEach(weekDays, id: \.comp) { day in
                    let isSelected = selectedDayOfWeek == day.comp
                    let isToday = Calendar.current.component(.weekday, from: Date()) == day.comp
                    let hasGoals = !scheduleManager.goalsForDay(day.comp).isEmpty
                    
                    Button(action: {
                        selectedDayOfWeek = day.comp
                    }) {
                        VStack(spacing: 4) {
                            Text(day.short)
                                .font(.system(size: 12, weight: .bold))
                            
                            Circle()
                                .fill(isSelected ? Color.white : (hasGoals ? Color.accentColor : Color.clear))
                                .frame(width: 5, height: 5)
                            
                            if isToday {
                                Text("TODAY")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundColor(isSelected ? .white : .accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            
            // Header for Selected Day Goals
            HStack {
                Text("Scheduled for \(weekdayName(selectedDayOfWeek))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { openAddGoalWindow() }) {
                    Label("Schedule Goal", systemImage: "plus")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 14)
            
            // Goals List for Selected Day
            ScrollView(.vertical, showsIndicators: true) {
                let currentDayGoals = scheduleManager.goalsForDay(selectedDayOfWeek)
                
                if currentDayGoals.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary.opacity(0.6))
                        Text("No goals scheduled for \(weekdayName(selectedDayOfWeek))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(currentDayGoals) { goal in
                            if let timer = timerManager.timers.first(where: { $0.id == goal.timerId }) {
                                HStack {
                                    Text(timer.emoji)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(timer.name)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text(goal.isRecurring ? "Recurring Weekly" : "One-time")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(timer.formattedGoal)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: timer.colorHex))
                                        .fontWeight(.semibold)
                                    
                                    Button(action: {
                                        scheduleManager.removeGoal(id: goal.id)
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.leading, 6)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
    }
    
    // MARK: - History Section (Past 7 Days)
    
    private var historySection: some View {
        VStack(spacing: 12) {
            let past7Days = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }.reversed()
            
            // 7-day past history grid
            HStack(spacing: 6) {
                ForEach(Array(past7Days), id: \.self) { date in
                    let isSelected = Calendar.current.isDate(selectedHistoryDate, inSameDayAs: date)
                    let isToday = Calendar.current.isDateInToday(date)
                    let totalSecs = isToday
                        ? timerManager.timers.reduce(0) { $0 + $1.elapsedSeconds }
                        : scheduleManager.totalSecondsCompleted(on: date)
                    let dayFormat = formatDateShort(date)

                    Button(action: {
                        selectedHistoryDate = date
                    }) {
                        VStack(spacing: 4) {
                            Text(isToday ? "TODAY" : dayFormat)
                                .font(.system(size: isToday ? 8 : 10, weight: .bold))

                            Circle()
                                .fill(totalSecs > 0 ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)

                            Text(formatDurationShort(totalSecs))
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(isSelected ? .white : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)

            // Detail logs for selected history day
            let isTodaySelected = Calendar.current.isDateInToday(selectedHistoryDate)
            let totalSelectedSecs = isTodaySelected
                ? timerManager.timers.reduce(0) { $0 + $1.elapsedSeconds }
                : scheduleManager.totalSecondsCompleted(on: selectedHistoryDate)

            HStack {
                Text(isTodaySelected ? "Today's Activity" : "Completed on \(formatDateFull(selectedHistoryDate))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDuration(totalSelectedSecs) + " total")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 14)

            ScrollView(.vertical, showsIndicators: true) {
                if isTodaySelected {
                    let activeTimers = timerManager.timers.filter { $0.elapsedSeconds > 0 }
                    if activeTimers.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 28))
                                .foregroundColor(.secondary.opacity(0.6))
                            Text("No timer activity recorded yet today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(activeTimers) { timer in
                                historyCardView(
                                    emoji: timer.emoji,
                                    name: timer.name,
                                    colorHex: timer.colorHex,
                                    elapsed: timer.elapsedSeconds,
                                    goal: timer.dailyGoalSeconds
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                } else {
                    let logs = scheduleManager.logsForDate(selectedHistoryDate)
                    if logs.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 28))
                                .foregroundColor(.secondary.opacity(0.6))
                            Text("No completed activity recorded for this day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(logs) { log in
                                let timer = timerManager.timers.first(where: { $0.id == log.timerId })
                                historyCardView(
                                    emoji: timer?.emoji ?? "⏱️",
                                    name: timer?.name ?? "Productivity Timer",
                                    colorHex: timer?.colorHex ?? "#3498DB",
                                    elapsed: log.secondsCompleted,
                                    goal: timer?.dailyGoalSeconds ?? 3600
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func historyCardView(emoji: String, name: String, colorHex: String, elapsed: Int, goal: Int) -> some View {
        let pct = goal > 0 ? Int((Double(elapsed) / Double(goal)) * 100) : 100
        let progress = goal > 0 ? min(1.0, Double(elapsed) / Double(goal)) : 1.0
        let isDone = elapsed >= goal && goal > 0

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(.system(size: 12, weight: .bold))
                            .lineLimit(1)

                        if isDone {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                    }

                    Text("\(formatDuration(elapsed)) / \(formatDuration(goal)) goal")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Progress Badge
                Text("\(pct)%")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isDone ? .green : Color(hex: colorHex))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill((isDone ? Color.green : Color(hex: colorHex)).opacity(0.12))
                    )
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 4)

                    Capsule()
                        .fill(isDone ? Color.green : Color(hex: colorHex))
                        .frame(width: max(0, min(geo.size.width * CGFloat(progress), geo.size.width)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    private func formatDurationShort(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func weekdayName(_ comp: Int) -> String {
        switch comp {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return "Day"
        }
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
        return formatter.string(from: date)
    }
    
    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func openAddGoalWindow() {
        let tm = timerManager
        let sm = scheduleManager
        let currentDay = selectedDayOfWeek
        WindowManager.shared.open(
            id: "schedule-goal",
            title: "Schedule Goal",
            width: 380, height: 390,
            view: NSHostingView(rootView:
                AddScheduleGoalSheet(
                    initialDay: currentDay,
                    onClose: { WindowManager.shared.close(id: "schedule-goal") },
                    onOpenAddTimer: {
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
                )
                .environmentObject(tm)
                .environmentObject(sm)
            )
        )
    }
}

// MARK: - Add Schedule Goal Sheet

public struct AddScheduleGoalSheet: View {
    var initialDay: Int = 2
    var onClose: (() -> Void)? = nil
    var onOpenAddTimer: (() -> Void)? = nil

    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var scheduleManager: ScheduleManager

    @State private var selectedTimerId: UUID = UUID()
    @State private var selectedDays: Set<Int> = [2]
    @State private var isRecurring: Bool = true

    private let weekDays: [(name: String, short: String, comp: Int)] = [
        ("Mon", "M", 2),
        ("Tue", "T", 3),
        ("Wed", "W", 4),
        ("Thu", "T", 5),
        ("Fri", "F", 6),
        ("Sat", "S", 7),
        ("Sun", "S", 1)
    ]

    public init(initialDay: Int = 2, onClose: (() -> Void)? = nil, onOpenAddTimer: (() -> Void)? = nil) {
        self.initialDay = initialDay
        self.onClose = onClose
        self.onOpenAddTimer = onOpenAddTimer
    }

    private func close() {
        if let onClose = onClose { onClose() } else { NSApp.keyWindow?.close() }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Label("Schedule Goal", systemImage: "calendar.badge.clock")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Timer Selection Dropdown + "+ New Timer" button
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("SELECT TIMER")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        onOpenAddTimer?()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "plus.circle.fill")
                            Text("New Timer")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Create a new timer")
                }

                if timerManager.timers.isEmpty {
                    HStack {
                        Text("No timers found.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: { onOpenAddTimer?() }) {
                            Text("Create Timer")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                } else {
                    Picker("Timer", selection: $selectedTimerId) {
                        ForEach(timerManager.timers) { timer in
                            Text("\(timer.emoji) \(timer.name) (\(timer.formattedGoal))").tag(timer.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Days of Week Selection (Multi-select)
            VStack(alignment: .leading, spacing: 6) {
                Text("PICK DAYS OF WEEK")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    ForEach(weekDays, id: \.comp) { day in
                        let isSelected = selectedDays.contains(day.comp)
                        Button(action: {
                            if isSelected {
                                if selectedDays.count > 1 {
                                    selectedDays.remove(day.comp)
                                }
                            } else {
                                selectedDays.insert(day.comp)
                            }
                        }) {
                            VStack(spacing: 2) {
                                Text(day.short)
                                    .font(.system(size: 12, weight: .bold))
                                Text(day.name)
                                    .font(.system(size: 8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Toggle Recurring Weekly
            VStack(alignment: .leading, spacing: 2) {
                Toggle("Recurring Weekly", isOn: $isRecurring)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(isRecurring ? "Auto-creates timer every week on chosen days" : "Applies only for the upcoming week")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.06)))

            Spacer()

            // Action Buttons
            HStack(spacing: 10) {
                Button(action: close) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)

                let canSave = !timerManager.timers.isEmpty && !selectedDays.isEmpty
                Button(action: {
                    if canSave {
                        scheduleManager.addGoals(for: selectedTimerId, daysOfWeek: selectedDays, isRecurring: isRecurring)
                        close()
                    }
                }) {
                    Text("Save Schedule")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(canSave ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(canSave ? Color.accentColor : Color.accentColor.opacity(0.35))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(18)
        .frame(width: 380, height: 390)
        .onAppear {
            selectedDays = [initialDay]
            if let first = timerManager.timers.first {
                selectedTimerId = first.id
            }
        }
        .onChange(of: timerManager.timers) { timers in
            if !timers.contains(where: { $0.id == selectedTimerId }), let first = timers.first {
                selectedTimerId = first.id
            }
        }
    }
}
