import SwiftUI

/// Manages color themes, preset selection, and custom 6-color theme building.
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    private let storage: LocalStorage
    
    @Published public var currentTheme: AppTheme = .ocean
    @Published public var custom1: AppTheme = .defaultCustom1
    @Published public var custom2: AppTheme = .defaultCustom2
    
    public init(storage: LocalStorage = .shared) {
        self.storage = storage
        let savedStorage = storage.loadThemeStorage()
        self.custom1 = savedStorage.custom1
        self.custom2 = savedStorage.custom2
        
        // Match current active theme
        self.currentTheme = self.theme(forId: savedStorage.currentThemeId)
    }
    
    public var allThemes: [AppTheme] {
        [AppTheme.ocean, AppTheme.midnight, AppTheme.forest, custom1, custom2]
    }
    
    public func theme(forId id: String) -> AppTheme {
        switch id {
        case AppTheme.ocean.id: return AppTheme.ocean
        case AppTheme.midnight.id: return AppTheme.midnight
        case AppTheme.forest.id: return AppTheme.forest
        case custom1.id: return custom1
        case custom2.id: return custom2
        default: return AppTheme.ocean
        }
    }
    
    public func selectTheme(id: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentTheme = self.theme(forId: id)
            self.persist()
        }
    }
    
    public func saveCustomTheme(
        slot: Int,
        name: String? = nil,
        primaryColor: String,
        highlightColor: String,
        backgroundColor: String,
        cardColor: String,
        textColor: String,
        accentColor: String
    ) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if slot == 1 {
                self.custom1 = AppTheme(
                    id: "custom_1",
                    name: name ?? "Custom 1",
                    primaryColor: primaryColor,
                    highlightColor: highlightColor,
                    backgroundColor: backgroundColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    accentColor: accentColor
                )
                if self.currentTheme.id == "custom_1" {
                    self.currentTheme = self.custom1
                }
            } else {
                self.custom2 = AppTheme(
                    id: "custom_2",
                    name: name ?? "Custom 2",
                    primaryColor: primaryColor,
                    highlightColor: highlightColor,
                    backgroundColor: backgroundColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    accentColor: accentColor
                )
                if self.currentTheme.id == "custom_2" {
                    self.currentTheme = self.custom2
                }
            }
            self.persist()
        }
    }
    
    private func persist() {
        let themeStorage = ThemeStorage(
            currentThemeId: currentTheme.id,
            custom1: custom1,
            custom2: custom2
        )
        storage.saveThemeStorage(themeStorage)
    }
    
    public func reload() {
        let savedStorage = storage.loadThemeStorage()
        self.custom1 = savedStorage.custom1
        self.custom2 = savedStorage.custom2
        self.currentTheme = self.theme(forId: savedStorage.currentThemeId)
    }
}

