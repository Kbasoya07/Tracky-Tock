import SwiftUI
import AppKit

/// Settings and preferences panel with data management, export/import, theme selection, and cleanup.
public struct SettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var scheduleManager: ScheduleManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localStorage: LocalStorage

    var onClose: (() -> Void)? = nil

    @State private var showingThemePicker: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false

    public init(onClose: (() -> Void)? = nil) { self.onClose = onClose }
    @AppStorage("showTimerInMenuBar") private var showTimerInMenuBar: Bool = true
    @AppStorage("showProgressRingInMenuBar") private var showProgressRingInMenuBar: Bool = true

    private func close() {
        if let onClose = onClose { onClose() } else { NSApp.keyWindow?.close() }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Settings & Preferences", systemImage: "gearshape.fill")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { close() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // SECTION 1: Appearance & Theme
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance & Themes")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showingThemePicker.toggle() }) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: themeManager.currentTheme.accentColor))
                                    .frame(width: 16, height: 16)
                                Text("Active: \(themeManager.currentTheme.name)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: showingThemePicker ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                        
                        if showingThemePicker {
                            ThemeSettingsView()
                                .environmentObject(themeManager)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    // Menu Bar Settings Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Menu Bar Appearance")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        // Toggle 1: Timer text
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show active timer text")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Shows emoji & elapsed time next to the icon")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showTimerInMenuBar)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))

                        // Toggle 2: Circular Progress Ring on logo
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show progress ring on icon")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Draws a circular progress ring around the ⏱️ logo")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showProgressRingInMenuBar)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                    }

                    Divider()

                    // SECTION 2: Timer & History Management
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data & Timers")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        // Reset All Timers for Today
                        Button(action: {
                            timerManager.resetAllTimersForToday()
                            showAlert(title: "Progress Reset", message: "All timer progress for today has been reset to 00:00.")
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle")
                                    .foregroundColor(.orange)
                                Text("Reset All Timers for Today")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                        
                        // Clear History (Older than 30 days)
                        Button(action: {
                            let removed = scheduleManager.clearHistoryOlderThan(days: 30)
                            showAlert(title: "History Cleaned", message: "Successfully removed \(removed) log entry(ies) older than 30 days.")
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.minus")
                                    .foregroundColor(.blue)
                                Text("Clear History (Older than 30 days)")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                    
                    // SECTION 3: Backup & Restore
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Backup & Sync")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            // Export Backup JSON
                            Button(action: {
                                exportBackupFile()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export Data (JSON)")
                                }
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            
                            // Import Backup JSON
                            Button(action: {
                                importBackupFile()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Import Data")
                                }
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Divider()
                    
                    // SECTION 4: App Lifecycle
                    VStack(spacing: 8) {
                        Button(role: .destructive, action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack {
                                Image(systemName: "power")
                                Text("Quit Tracky-Tock")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)))
                        }
                        .buttonStyle(.plain)
                        
                        Text("Tracky-Tock v1.0 • Built with Swift & SwiftUI")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 400, height: 480)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showingAlert = true
    }
    
    // MARK: - Native Export / Import Handlers
    
    private func exportBackupFile() {
        guard let backupData = localStorage.exportAllData() else {
            showAlert(title: "Export Failed", message: "Could not serialize application data.")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = "TrackyTock_Backup_\(formatDateForFile(Date())).json"
        savePanel.title = "Save Tracky-Tock Backup"
        
        if savePanel.runModal() == .OK, let targetURL = savePanel.url {
            do {
                try backupData.write(to: targetURL, options: .atomic)
                showAlert(title: "Export Succeeded", message: "Saved backup to \(targetURL.lastPathComponent)")
            } catch {
                showAlert(title: "Export Error", message: error.localizedDescription)
            }
        }
    }
    
    private func importBackupFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.title = "Select Tracky-Tock Backup JSON"
        
        if openPanel.runModal() == .OK, let selectedURL = openPanel.url {
            do {
                let data = try Data(contentsOf: selectedURL)
                let backup = try localStorage.importBackupData(data)
                
                // Refresh all managers
                timerManager.reloadTimers()
                scheduleManager.reload()
                themeManager.reload()
                
                showAlert(title: "Import Succeeded", message: "Imported \(backup.timers.count) timers and \(backup.history.count) history logs.")
            } catch {
                showAlert(title: "Import Error", message: "Invalid backup file: \(error.localizedDescription)")
            }
        }
    }
    
    private func formatDateForFile(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
