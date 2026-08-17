import SwiftUI

/// Creates a new timer with support for both Target Daily Goals and Open-Ended (No Limit) timers.
public struct AddTimerView: View {
    var onClose: (() -> Void)? = nil
    @EnvironmentObject var timerManager: TimerManager

    @State private var name: String = ""
    @State private var selectedEmoji: String = "📚"
    @State private var selectedColorHex: String = "#3498DB"
    @State private var isUnlimitedMode: Bool = false

    // Goal — stored as editable text for direct input
    @State private var hoursText: String = "1"
    @State private var minutesText: String = "0"

    // Derived validated values
    private var goalHours: Int { min(23, max(0, Int(hoursText) ?? 0)) }
    private var goalMinutes: Int { min(59, max(0, Int(minutesText) ?? 0)) }
    private var totalGoalSeconds: Int { isUnlimitedMode ? 0 : (goalHours * 3600 + goalMinutes * 60) }

    private let emojis: [String] = [
        "📚","💻","🏃","🎨","✍️","🧠","☕️","🧘","📈","🚀",
        "🔬","🎯","🎧","💡","📝","🛠️","💼","🏋️","⚡️","🎮"
    ]

    private let colors: [(hex: String, name: String)] = [
        ("#3498DB","Blue"), ("#2ECC71","Green"), ("#E74C3C","Red"),
        ("#F39C12","Orange"), ("#9B59B6","Purple"), ("#1ABC9C","Teal"),
        ("#E91E63","Pink"), ("#FF5722","Deep Orange"), ("#607D8B","Steel")
    ]

    public init(onClose: (() -> Void)? = nil) { self.onClose = onClose }

    private func close() {
        if let onClose = onClose { onClose() } else { NSApp.keyWindow?.close() }
    }

    private var goalLabel: String {
        if isUnlimitedMode {
            return "No Limit (Open Timer)"
        } else if goalHours > 0 && goalMinutes > 0 {
            return "\(goalHours)h \(goalMinutes)m"
        } else if goalHours > 0 {
            return "\(goalHours)h"
        } else if goalMinutes > 0 {
            return "\(goalMinutes)m"
        } else {
            return "Set a goal"
        }
    }

    private var canCreate: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && (isUnlimitedMode || totalGoalSeconds > 0)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Header ──
            HStack {
                Label("New Timer", systemImage: "timer")
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

            // ── Timer Name ──
            VStack(alignment: .leading, spacing: 4) {
                Text("TIMER NAME").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                TextField("e.g. Deep Work, Reading, Gaming, Project X…", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
            }

            // ── Emoji Grid ──
            VStack(alignment: .leading, spacing: 4) {
                Text("EMOJI").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 10),
                    spacing: 4
                ) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: { selectedEmoji = emoji }) {
                            Text(emoji)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedEmoji == emoji
                                            ? Color(hex: selectedColorHex).opacity(0.22)
                                            : Color.gray.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(selectedEmoji == emoji
                                                    ? Color(hex: selectedColorHex)
                                                    : Color.clear, lineWidth: 1.5)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // ── Color Swatches ──
            VStack(alignment: .leading, spacing: 4) {
                Text("COLOR").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                HStack(spacing: 7) {
                    ForEach(colors, id: \.hex) { c in
                        Button(action: { selectedColorHex = c.hex }) {
                            Circle()
                                .fill(Color(hex: c.hex))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().stroke(Color.white,
                                        lineWidth: selectedColorHex == c.hex ? 2.5 : 0)
                                )
                                .shadow(radius: selectedColorHex == c.hex ? 2 : 0)
                                .scaleEffect(selectedColorHex == c.hex ? 1.2 : 1.0)
                                .animation(.spring(response: 0.2), value: selectedColorHex)
                        }
                        .buttonStyle(.plain)
                        .help(c.name)
                    }
                }
            }

            // ── Mode: Daily Goal vs Open-Ended ──
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("TIMER TYPE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                    Spacer()
                    Text(goalLabel)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: selectedColorHex))
                }

                // Mode switch tabs
                HStack(spacing: 6) {
                    Button(action: { isUnlimitedMode = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                            Text("Target Goal")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(!isUnlimitedMode ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(!isUnlimitedMode ? Color(hex: selectedColorHex) : Color.secondary.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { isUnlimitedMode = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "infinity")
                            Text("No Limit (Open)")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isUnlimitedMode ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isUnlimitedMode ? Color(hex: selectedColorHex) : Color.secondary.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }

                if isUnlimitedMode {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title3)
                            .foregroundColor(Color(hex: selectedColorHex))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Open-Ended Timer")
                                .font(.system(size: 11, weight: .bold))
                            Text("Counts up continuously from 00:00 with no time ceiling.")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: selectedColorHex).opacity(0.08)))
                } else {
                    // Goal time steppers
                    HStack(spacing: 10) {
                        // Hours
                        VStack(spacing: 4) {
                            Text("Hours (0–23)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)

                            HStack(spacing: 6) {
                                Button(action: {
                                    let v = max(0, (Int(hoursText) ?? 0) - 1)
                                    hoursText = "\(v)"
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }.buttonStyle(.plain)

                                TextField("0", text: $hoursText)
                                    .frame(width: 40)
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                                    .onChange(of: hoursText) { val in
                                        let cleaned = val.filter { $0.isNumber }
                                        if let n = Int(cleaned) {
                                            hoursText = "\(min(23, n))"
                                        } else if cleaned.isEmpty {
                                            hoursText = ""
                                        } else {
                                            hoursText = cleaned
                                        }
                                    }

                                Button(action: {
                                    let v = min(23, (Int(hoursText) ?? 0) + 1)
                                    hoursText = "\(v)"
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: selectedColorHex))
                                }.buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.07)))

                        Text(":")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.secondary)

                        // Minutes
                        VStack(spacing: 4) {
                            Text("Minutes (0–59)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)

                            HStack(spacing: 6) {
                                Button(action: {
                                    let v = max(0, (Int(minutesText) ?? 0) - 1)
                                    minutesText = "\(v)"
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }.buttonStyle(.plain)

                                TextField("0", text: $minutesText)
                                    .frame(width: 40)
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                                    .onChange(of: minutesText) { val in
                                        let cleaned = val.filter { $0.isNumber }
                                        if let n = Int(cleaned) {
                                            minutesText = "\(min(59, n))"
                                        } else if cleaned.isEmpty {
                                            minutesText = ""
                                        } else {
                                            minutesText = cleaned
                                        }
                                    }

                                Button(action: {
                                    let v = min(59, (Int(minutesText) ?? 0) + 1)
                                    minutesText = "\(v)"
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: selectedColorHex))
                                }.buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.07)))
                    }

                    if totalGoalSeconds == 0 {
                        Text("⚠️ Set at least 1 minute or choose 'No Limit'")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer(minLength: 2)

            // ── Action Buttons ──
            HStack(spacing: 10) {
                Button(action: close) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)

                Button(action: { if canCreate { createTimer() } }) {
                    Text(isUnlimitedMode ? "Create Open Timer" : "Create Goal Timer")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(canCreate ? .white : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(canCreate
                                    ? Color(hex: selectedColorHex)
                                    : Color(hex: selectedColorHex).opacity(0.35))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(!canCreate)
            }
        }
        .padding(18)
        .frame(width: 380, height: 460)
    }

    private func createTimer() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let goalSecs = isUnlimitedMode ? 0 : totalGoalSeconds
        if !isUnlimitedMode && goalSecs == 0 { return }

        timerManager.addTimer(TimerItem(
            name: trimmed,
            emoji: selectedEmoji,
            colorHex: selectedColorHex,
            dailyGoalSeconds: goalSecs,
            elapsedSeconds: 0,
            isRunning: false
        ))
        close()
    }
}
