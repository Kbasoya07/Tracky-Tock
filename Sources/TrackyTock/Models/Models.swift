import Foundation

// MARK: - Timer Item Model
public struct TimerItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String          // e.g., "Studying"
    public var emoji: String         // e.g., "📚"
    public var colorHex: String      // e.g., "#FF6B6B"
    public var dailyGoalSeconds: Int // e.g., 14400 (4 hours)
    public var elapsedSeconds: Int   // accumulated today
    public var isRunning: Bool
    public var isScheduled: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "⏱️",
        colorHex: String = "#FF6B6B",
        dailyGoalSeconds: Int = 14400,
        elapsedSeconds: Int = 0,
        isRunning: Bool = false,
        isScheduled: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.dailyGoalSeconds = dailyGoalSeconds
        self.elapsedSeconds = elapsedSeconds
        self.isRunning = isRunning
        self.isScheduled = isScheduled
        self.createdAt = createdAt
    }
    
    public var isUnlimited: Bool {
        return dailyGoalSeconds == 0
    }

    public var isCompleted: Bool {
        return dailyGoalSeconds > 0 && elapsedSeconds >= dailyGoalSeconds
    }
    
    public var progress: Double {
        guard dailyGoalSeconds > 0 else { return 1.0 }
        return min(Double(elapsedSeconds) / Double(dailyGoalSeconds), 1.0)
    }
    
    public var formattedElapsed: String {
        let hours = elapsedSeconds / 3600
        let mins = (elapsedSeconds % 3600) / 60
        let secs = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, mins, secs)
        } else {
            return String(format: "%02dm %02ds", mins, secs)
        }
    }
    
    public var formattedGoal: String {
        if isUnlimited {
            return "No Limit"
        }
        let hours = dailyGoalSeconds / 3600
        let mins = (dailyGoalSeconds % 3600) / 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    public var remainingSeconds: Int {
        if isUnlimited { return 0 }
        return max(0, dailyGoalSeconds - elapsedSeconds)
    }

    public var formattedRemaining: String {
        if isUnlimited {
            return "Open-ended"
        }
        let r = remainingSeconds
        let hours = r / 3600
        let mins = (r % 3600) / 60
        let secs = r % 60
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, mins, secs)
        } else {
            return String(format: "%02dm %02ds", mins, secs)
        }
    }
}


// MARK: - Scheduled Goal Model
public struct ScheduledGoal: Identifiable, Codable, Equatable {
    public let id: UUID
    public var timerId: UUID         // links to TimerItem
    public var dayOfWeek: Int        // 1 = Sunday, 2 = Monday... (Calendar component)
    public var isRecurring: Bool
    public var reminderEnabled: Bool // true by default
    
    public init(
        id: UUID = UUID(),
        timerId: UUID,
        dayOfWeek: Int,
        isRecurring: Bool = true,
        reminderEnabled: Bool = true
    ) {
        self.id = id
        self.timerId = timerId
        self.dayOfWeek = dayOfWeek
        self.isRecurring = isRecurring
        self.reminderEnabled = reminderEnabled
    }
}

// MARK: - Daily Log Model
public struct DailyLog: Identifiable, Codable, Equatable {
    public let id: UUID
    public let date: Date
    public let timerId: UUID
    public let secondsCompleted: Int
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        timerId: UUID,
        secondsCompleted: Int
    ) {
        self.id = id
        self.date = date
        self.timerId = timerId
        self.secondsCompleted = secondsCompleted
    }
}

// MARK: - App Theme Model
public struct AppTheme: Identifiable, Codable, Equatable {
    public let id: String            // "ocean", "sunset", etc.
    public var name: String
    public var primaryColor: String  // Hex
    public var highlightColor: String
    public var backgroundColor: String
    public var cardColor: String
    public var textColor: String
    public var accentColor: String
    
    public init(
        id: String,
        name: String,
        primaryColor: String,
        highlightColor: String,
        backgroundColor: String,
        cardColor: String,
        textColor: String,
        accentColor: String
    ) {
        self.id = id
        self.name = name
        self.primaryColor = primaryColor
        self.highlightColor = highlightColor
        self.backgroundColor = backgroundColor
        self.cardColor = cardColor
        self.textColor = textColor
        self.accentColor = accentColor
    }
}

// MARK: - Sample Previews & Fixtures
#if DEBUG
public extension TimerItem {
    static let sampleStudying = TimerItem(
        name: "Studying",
        emoji: "📚",
        colorHex: "#FF6B6B",
        dailyGoalSeconds: 14400,
        elapsedSeconds: 7200,
        isRunning: false
    )
    
    static let sampleDeepWork = TimerItem(
        name: "Deep Work",
        emoji: "💻",
        colorHex: "#4ECDC4",
        dailyGoalSeconds: 10800,
        elapsedSeconds: 3600,
        isRunning: true
    )
    
    static let sampleList: [TimerItem] = [
        sampleStudying,
        sampleDeepWork,
        TimerItem(name: "Workout", emoji: "🏃‍♂️", colorHex: "#FFD166", dailyGoalSeconds: 3600, elapsedSeconds: 1800, isRunning: false)
    ]
}

public extension ScheduledGoal {
    static let sample = ScheduledGoal(
        timerId: UUID(),
        dayOfWeek: 2, // Monday
        isRecurring: true,
        reminderEnabled: true
    )
}

public extension DailyLog {
    static let sample = DailyLog(
        timerId: UUID(),
        secondsCompleted: 3600
    )
}
#endif

// MARK: - App Theme Presets

public extension AppTheme {
    static let ocean = AppTheme(
        id: "ocean",
        name: "Ocean (Blue)",
        primaryColor: "#0D47A1",
        highlightColor: "#4FC3F7",
        backgroundColor: "#E3F2FD",
        cardColor: "#BBDEFB",
        textColor: "#0D47A1",
        accentColor: "#4FC3F7"
    )
    
    static let midnight = AppTheme(
        id: "midnight",
        name: "Midnight (Dark)",
        primaryColor: "#1A1A2E",
        highlightColor: "#E94560",
        backgroundColor: "#16213E",
        cardColor: "#0F3460",
        textColor: "#FFFFFF",
        accentColor: "#E94560"
    )
    
    static let forest = AppTheme(
        id: "forest",
        name: "Forest (Green)",
        primaryColor: "#2D5016",
        highlightColor: "#76C893",
        backgroundColor: "#F1F8E9",
        cardColor: "#DCEDC8",
        textColor: "#1B5E20",
        accentColor: "#76C893"
    )
    
    static let defaultCustom1 = AppTheme(
        id: "custom_1",
        name: "Custom 1",
        primaryColor: "#4A148C",
        highlightColor: "#BA68C8",
        backgroundColor: "#F3E5F5",
        cardColor: "#E1BEE7",
        textColor: "#4A148C",
        accentColor: "#AB47BC"
    )
    
    static let defaultCustom2 = AppTheme(
        id: "custom_2",
        name: "Custom 2",
        primaryColor: "#E65100",
        highlightColor: "#FFB74D",
        backgroundColor: "#FFF3E0",
        cardColor: "#FFE0B2",
        textColor: "#E65100",
        accentColor: "#FFA726"
    )
    
    static let presets: [AppTheme] = [ocean, midnight, forest]
}

// MARK: - Theme Storage Container
public struct ThemeStorage: Codable, Equatable {
    public var currentThemeId: String
    public var custom1: AppTheme
    public var custom2: AppTheme
    
    public init(
        currentThemeId: String = "ocean",
        custom1: AppTheme = .defaultCustom1,
        custom2: AppTheme = .defaultCustom2
    ) {
        self.currentThemeId = currentThemeId
        self.custom1 = custom1
        self.custom2 = custom2
    }
}


// MARK: - Cached Quote Model
public struct CachedQuote: Codable, Equatable {
    public var quote: String
    public var author: String
    public var date: Date
    
    public init(quote: String, author: String, date: Date = Date()) {
        self.quote = quote
        self.author = author
        self.date = date
    }
}

