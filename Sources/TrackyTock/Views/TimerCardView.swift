import SwiftUI

/// Animated card with spring entrance, pulsing outer ring, digit bounce tick, and 16px rounded corners.
public struct TimerCardView: View {
    let timer: TimerItem
    @EnvironmentObject var timerManager: TimerManager

    // Hover / interaction states
    @State private var isHovered: Bool = false
    @State private var isPlayButtonHovered: Bool = false
    @State private var isDoneButtonHovered: Bool = false

    // Animation states
    @State private var appeared: Bool = false
    @State private var isPulsing: Bool = false
    @State private var digitBounce: Bool = false
    @State private var playPressed: Bool = false
    @State private var ringGlow: Double = 0.2

    private var themeColor: Color { Color(hex: timer.colorHex) }
    private var isOvertime: Bool { timer.dailyGoalSeconds > 0 && timer.elapsedSeconds > timer.dailyGoalSeconds }
    private var overtimeSeconds: Int { max(0, timer.elapsedSeconds - timer.dailyGoalSeconds) }

    public init(timer: TimerItem) { self.timer = timer }

    public var body: some View {
        VStack(spacing: 8) {
            topRowView
            progressBarView
            actionRowView
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(cardBackgroundView)
        .scaleEffect(isHovered ? 1.005 : 1.0)
        .scaleEffect(appeared ? 1.0 : 0.88)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                appeared = true
            }
            if timer.isRunning {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    ringGlow = 0.55
                }
            }
        }
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var topRowView: some View {
        HStack(alignment: .center, spacing: 12) {
            progressRingView
            timerInfoView
            playButtonView
        }
    }

    @ViewBuilder
    private var progressRingView: some View {
        ZStack {
            if timer.isRunning {
                Circle()
                    .stroke(themeColor.opacity(isPulsing ? 0.45 : 0.08), lineWidth: 5)
                    .frame(width: 58, height: 58)
                    .scaleEffect(isPulsing ? 1.22 : 1.0)
            }

            Circle()
                .stroke(themeColor.opacity(0.18), lineWidth: 4)
                .frame(width: 44, height: 44)

            Circle()
                .trim(from: 0, to: CGFloat(min(timer.progress, 1.0)))
                .stroke(
                    timer.isCompleted ? (isOvertime ? Color.orange : Color.yellow) : themeColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 44, height: 44)
                .animation(.easeInOut(duration: 0.4), value: timer.progress)
                .shadow(color: themeColor.opacity(timer.isRunning ? ringGlow : 0), radius: 4)

            Text(timer.emoji)
                .font(.system(size: 20))
                .scaleEffect(timer.isRunning && isPulsing ? 1.12 : 1.0)
                .animation(.easeInOut(duration: 2.0), value: isPulsing)
        }
        .onAppear { startOrStopPulse(running: timer.isRunning) }
        .onChange(of: timer.isRunning) { startOrStopPulse(running: $0) }
    }

    @ViewBuilder
    private var timerInfoView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Text(timer.name)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                if timer.isScheduled {
                    Text("📅")
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(Color.orange.opacity(0.2)))
                }
                if timer.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(isOvertime ? .orange : .yellow)
                        .font(.system(size: 10))
                }
            }

            HStack(spacing: 3) {
                Text(timer.formattedElapsed)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .scaleEffect(digitBounce ? 1.06 : 1.0, anchor: .leading)
                Text("/ \(timer.formattedGoal)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                if isOvertime {
                    Text("+\(formatOvertime(overtimeSeconds))")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
            }
            .onChange(of: timer.elapsedSeconds) { _ in
                guard timer.isRunning else { return }
                withAnimation(.spring(response: 0.12, dampingFraction: 0.4)) { digitBounce = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.12, dampingFraction: 0.5)) { digitBounce = false }
                }
            }

            HStack(spacing: 3) {
                if timer.isUnlimited {
                    Image(systemName: "infinity")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text("Open Timer")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                } else if !timer.isCompleted {
                    Image(systemName: "hourglass.tophalf.filled")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text("\(timer.formattedRemaining) left")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.green)
                    Text(isOvertime ? "Overtime Active" : "Goal reached!")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isOvertime ? .orange : .green)
                }
                if timer.isRunning {
                    Spacer(minLength: 0)
                    HStack(spacing: 3) {
                        Circle()
                            .fill(themeColor)
                            .frame(width: 5, height: 5)
                            .scaleEffect(isPulsing ? 1.3 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                        Text("Live")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(themeColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var playButtonView: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { playPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { playPressed = false }
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                timerManager.toggleTimer(id: timer.id)
            }
        }) {
            Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(timer.isRunning ? themeColor : Color.primary.opacity(0.55))
                .scaleEffect(playPressed ? 0.88 : (isPlayButtonHovered ? 1.09 : 1.0))
        }
        .buttonStyle(.plain)
        .onHover { isPlayButtonHovered = $0 }
        .help(timer.isRunning ? "Pause timer (Space)" : "Start timer (Space)")
    }

    @ViewBuilder
    private var progressBarView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.14)).frame(height: 5)
                Capsule()
                    .fill(
                        timer.isUnlimited
                            ? (timer.isRunning ? themeColor : themeColor.opacity(0.35))
                            : (timer.isCompleted
                                ? (isOvertime ? Color.orange : Color.yellow)
                                : themeColor)
                    )
                    .frame(
                        width: timer.isUnlimited
                            ? geo.size.width
                            : max(0, min(geo.size.width * CGFloat(timer.progress), geo.size.width)),
                        height: 5
                    )
                    .animation(.easeInOut(duration: 0.35), value: timer.progress)
            }
        }
        .frame(height: 5)
    }

    @ViewBuilder
    private var actionRowView: some View {
        HStack {
            Button(action: { markDoneForToday() }) {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.circle")
                    Text("Done for today")
                }
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(Capsule().fill(isDoneButtonHovered
                    ? Color.secondary.opacity(0.2)
                    : Color.secondary.opacity(0.09)))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .onHover { isDoneButtonHovered = $0 }

            Spacer()

            Menu {
                Button(action: { timerManager.resetTimer(id: timer.id) }) {
                    Label("Reset to 0", systemImage: "arrow.counterclockwise")
                }
                Divider()
                Button(role: .destructive, action: { timerManager.deleteTimer(id: timer.id) }) {
                    Label("Delete Timer", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
            }
            .menuStyle(.borderlessButton)
            .frame(width: 28)
        }
    }

    @ViewBuilder
    private var cardBackgroundView: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(themeColor.opacity(isHovered ? 0.13 : 0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        timer.isCompleted
                            ? (isOvertime ? Color.orange.opacity(0.7) : Color.yellow.opacity(0.7))
                            : (timer.isRunning ? themeColor.opacity(0.6) : themeColor.opacity(isHovered ? 0.22 : 0.12)),
                        lineWidth: (timer.isCompleted || timer.isRunning) ? 1.5 : 1.0
                    )
            )
            .shadow(
                color: timer.isRunning ? themeColor.opacity(isPulsing ? 0.25 : 0.12) : .clear,
                radius: timer.isRunning ? 8 : 0, x: 0, y: 2
            )
    }

    // MARK: - Helpers

    private func startOrStopPulse(running: Bool) {
        if running {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                ringGlow = 0.55
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPulsing = false
                ringGlow = 0.2
            }
        }
    }

    private func formatOvertime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }

    private func markDoneForToday() {
        var updated = timer
        updated.isRunning = false
        if !updated.isUnlimited && updated.elapsedSeconds < updated.dailyGoalSeconds {
            updated.elapsedSeconds = updated.dailyGoalSeconds
        }
        timerManager.updateTimer(updated)
    }
}
