import Foundation

/// Complete backup container for full export and import of user data.
public struct AppBackupData: Codable {
    public var version: String
    public var exportDate: Date
    public var timers: [TimerItem]
    public var schedule: [ScheduledGoal]
    public var history: [DailyLog]
    public var theme: ThemeStorage
    
    public init(
        version: String = "1.0",
        exportDate: Date = Date(),
        timers: [TimerItem],
        schedule: [ScheduledGoal],
        history: [DailyLog],
        theme: ThemeStorage
    ) {
        self.version = version
        self.exportDate = exportDate
        self.timers = timers
        self.schedule = schedule
        self.history = history
        self.theme = theme
    }
}

/// Robust JSON-based local storage persisting all app data in Application Support with export/import support.
public class LocalStorage: ObservableObject {
    public static let shared = LocalStorage()
    
    private let fileManager = FileManager.default
    public let appFolderURL: URL
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    // File names
    private let timersFileName = "timers.json"
    private let scheduleFileName = "schedule.json"
    private let historyFileName = "history.json"
    private let themeFileName = "theme.json"
    private let quoteFileName = "quote.json"
    
    public init(customFolderURL: URL? = nil) {
        if let customFolder = customFolderURL {
            self.appFolderURL = customFolder
        } else {
            // Resolve Application Support directory for Tracky-Tock
            if let baseAppSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                self.appFolderURL = baseAppSupport.appendingPathComponent("TrackyTock", isDirectory: true)
            } else {
                self.appFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TrackyTock", isDirectory: true)
            }
        }
        
        createAppDirectoryIfNeeded()
    }
    
    private func createAppDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: appFolderURL.path) {
            try? fileManager.createDirectory(at: appFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - Generic Persistence Helpers
    
    public func save<T: Encodable>(_ object: T, to fileName: String) {
        createAppDirectoryIfNeeded()
        let fileURL = appFolderURL.appendingPathComponent(fileName)
        do {
            let data = try encoder.encode(object)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("LocalStorage: Failed to save \(fileName): \(error.localizedDescription)")
        }
    }
    
    public func load<T: Decodable>(from fileName: String, as type: T.Type) -> T? {
        let fileURL = appFolderURL.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(type, from: data)
        } catch {
            print("LocalStorage: Failed to load \(fileName): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Specific Domain Methods
    
    // Timers
    public func saveTimers(_ timers: [TimerItem]) {
        save(timers, to: timersFileName)
    }
    
    public func loadTimers() -> [TimerItem] {
        return load(from: timersFileName, as: [TimerItem].self) ?? []
    }
    
    // Schedule
    public func saveSchedule(_ schedule: [ScheduledGoal]) {
        save(schedule, to: scheduleFileName)
    }
    
    public func loadSchedule() -> [ScheduledGoal] {
        return load(from: scheduleFileName, as: [ScheduledGoal].self) ?? []
    }
    
    // History (Filtered for last 90 days by default)
    public func saveHistory(_ history: [DailyLog]) {
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let trimmedHistory = history.filter { $0.date >= ninetyDaysAgo }
        save(trimmedHistory, to: historyFileName)
    }
    
    public func loadHistory() -> [DailyLog] {
        let history = load(from: historyFileName, as: [DailyLog].self) ?? []
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        return history.filter { $0.date >= ninetyDaysAgo }
    }
    
    /// Clears history logs older than specified days (e.g. 30 days) and returns count of removed items
    public func clearHistoryOlderThan(days: Int = 30) -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let currentHistory = loadHistory()
        let retained = currentHistory.filter { $0.date >= cutoffDate }
        let removedCount = currentHistory.count - retained.count
        save(retained, to: historyFileName)
        return removedCount
    }
    
    // Theme Storage
    public func saveThemeStorage(_ themeStorage: ThemeStorage) {
        save(themeStorage, to: themeFileName)
    }
    
    public func loadThemeStorage() -> ThemeStorage {
        return load(from: themeFileName, as: ThemeStorage.self) ?? ThemeStorage()
    }
    
    // Quote
    public func saveQuote(_ cachedQuote: CachedQuote) {
        save(cachedQuote, to: quoteFileName)
    }
    
    public func loadQuote() -> CachedQuote? {
        return load(from: quoteFileName, as: CachedQuote.self)
    }
    
    // MARK: - Export & Import Backup
    
    public func exportAllData() -> Data? {
        let backup = AppBackupData(
            timers: loadTimers(),
            schedule: loadSchedule(),
            history: loadHistory(),
            theme: loadThemeStorage()
        )
        return try? encoder.encode(backup)
    }
    
    public func importBackupData(_ data: Data) throws -> AppBackupData {
        let backup = try decoder.decode(AppBackupData.self, from: data)
        saveTimers(backup.timers)
        saveSchedule(backup.schedule)
        saveHistory(backup.history)
        saveThemeStorage(backup.theme)
        return backup
    }
}
