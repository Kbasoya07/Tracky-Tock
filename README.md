# Tracky-Tock ⏱️

> **The modern, minimalist productivity timer and habit tracker built exclusively for macOS.**

Track multiple focus sessions simultaneously, schedule recurring goals, track 7-day visual history with progress completion bars, and stay motivated with 255 curated quotes — all from your macOS menu bar.

---

## 🌟 Key Features

- **Menu Bar First & Featherlight**: Lives quietly in your menu bar (`LSUIElement`). No Dock clutter.
- **Live Menu Bar Progress Ring & Ticking Display**: Subtle circular progress ring around the `⏱️` logo + steady ticking `HH:MM` timer.
- **Multiple Simultaneous Timers**: Run multiple timers with individual daily goals, custom emojis, and theme colors.
- **Overtime & Goal Celebrations**: Automatic overtime tracking + animated confetti celebrations when goals are reached.
- **Weekly Schedule & Calendar**: Schedule recurring or one-time goals across days of the week with quick-create integrations.
- **7-Day Visual History**: Live progress bars, goal percentage badges, and daily completed session summaries.
- **255 Inspiring Daily Quotes**: Auto-rotating daily quotes + instant random cycle (`🔄`) with multiline adaptive typography.
- **Theme Studio & Color Builder**: 3 built-in presets (Ocean, Midnight, Forest) + 2 custom theme slots with 16 quick-tap swatches and direct `#HEX` input.
- **100% Local & Private**: All data is saved locally on your Mac with JSON backup export and import.

---

## 🚀 Quick Download & Run

1. Download **`Tracky-Tock-v1.0.0.zip`** from [Releases](../../releases).
2. Unzip the file and move `Tracky-Tock.app` to your `/Applications` folder.
3. Right-click `Tracky-Tock.app` → Click **Open** → Click **Open** to launch.

---

## 🛠️ Build from Source

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/tracky-tock.git
cd tracky-tock

# 2. Compile & package with 1 command
./package_release.sh

# 3. Launch the app
open "Tracky-Tock.app"
```

The distributable release package will be generated at `dist/Tracky-Tock-v1.0.0.zip`.

---

## ⌨️ Global Shortcuts

| Shortcut | Action |
|---|---|
| `Space` | Start / Pause active timer |
| `⌘ N` | Create new timer |
| `⌘ ,` | Open Settings & Preferences |

---

## 📦 Project Structure

```
TrackyTock/
├── .github/workflows/
│   └── release.yml              ← Automated GitHub Release CI/CD
├── Sources/TrackyTock/
│   ├── TrackyTockApp.swift      ← App entry point & MenuBarExtra
│   ├── Models/
│   │   └── Models.swift         ← TimerItem, ScheduledGoal, DailyLog, AppTheme
│   ├── Managers/
│   │   ├── LocalStorage.swift   ← Local JSON storage layer
│   │   ├── TimerManager.swift   ← Main timer engine
│   │   ├── ScheduleManager.swift← Goals & history logging
│   │   ├── ThemeManager.swift   ← Theme switcher & storage
│   │   └── QuoteManager.swift   ← 255 curated quote database
│   └── Views/
│       ├── MenuBarView.swift    ← Live menu bar icon & text
│       ├── ContentView.swift    ← Main popover window & quote banner
│       ├── TimerCardView.swift  ← Animated timer cards
│       ├── AddTimerView.swift   ← Custom timer creator
│       ├── CalendarView.swift   ← Schedule & 7-day visual history
│       ├── ThemeSettingsView.swift ← Theme studio & color builder
│       └── SettingsView.swift   ← Preferences & data management
├── package_release.sh           ← 1-click build & packaging script
└── Tracky-Tock.app/             ← Native macOS App Bundle
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
