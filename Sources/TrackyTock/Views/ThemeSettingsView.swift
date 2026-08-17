import SwiftUI

/// Interactive theme customizer with quick-tap color palettes, direct HEX editing, live preview, and 2 custom save slots.
public struct ThemeSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    // 6 Custom Theme Color Hex Strings
    @State private var primaryHex: String = "#4A148C"
    @State private var highlightHex: String = "#BA68C8"
    @State private var backgroundHex: String = "#1E1E2E"
    @State private var cardHex: String = "#2D2D44"
    @State private var textHex: String = "#FFFFFF"
    @State private var accentHex: String = "#AB47BC"

    // Currently selected property for quick-swatch editing
    @State private var selectedProperty: ThemeColorProperty = .accent
    @State private var saveSuccessMessage: String? = nil

    @State private var isCustom1Hovered: Bool = false
    @State private var isCustom2Hovered: Bool = false

    enum ThemeColorProperty: String, CaseIterable {
        case accent = "Accent"
        case primary = "Primary"
        case card = "Card"
        case background = "Background"
        case text = "Text"
        case highlight = "Highlight"
    }

    // 16 Popular, vibrant macOS colors for instant 1-tap customization
    private let swatchPalette: [String] = [
        "#3498DB", "#2ECC71", "#E74C3C", "#F39C12",
        "#9B59B6", "#1ABC9C", "#E91E63", "#FF5722",
        "#00C7BE", "#AF52DE", "#FF9500", "#30B0C7",
        "#1C1C1E", "#2C2C2E", "#F2F2F7", "#FFFFFF"
    ]

    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 14) {

                // SECTION 1: Preset & Custom Themes Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("SELECT ACTIVE THEME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.65))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(themeManager.allThemes) { theme in
                            let isSelected = themeManager.currentTheme.id == theme.id
                            Button(action: {
                                themeManager.selectTheme(id: theme.id)
                                loadFromTheme(theme)
                            }) {
                                HStack(spacing: 6) {
                                    HStack(spacing: 3) {
                                        Circle().fill(Color(hex: theme.primaryColor)).frame(width: 10, height: 10)
                                        Circle().fill(Color(hex: theme.accentColor)).frame(width: 10, height: 10)
                                        Circle().fill(Color(hex: theme.cardColor)).frame(width: 10, height: 10)
                                    }

                                    Text(theme.name)
                                        .font(.system(size: 11, weight: .semibold))
                                        .lineLimit(1)
                                        .foregroundColor(Color(hex: theme.textColor))

                                    Spacer(minLength: 2)

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(hex: theme.accentColor))
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: theme.cardColor).opacity(0.85))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    isSelected ? Color(hex: theme.accentColor) : Color.primary.opacity(0.08),
                                                    lineWidth: isSelected ? 2.0 : 1.0
                                                )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider()

                // SECTION 2: Custom Theme Builder
                VStack(alignment: .leading, spacing: 10) {
                    Text("CUSTOM THEME BUILDER")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: themeManager.currentTheme.textColor).opacity(0.65))

                    // 1. Property Picker Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(ThemeColorProperty.allCases, id: \.self) { prop in
                                let isSel = selectedProperty == prop
                                let currentColor = hexForProperty(prop)

                                Button(action: { selectedProperty = prop }) {
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color(hex: currentColor))
                                            .frame(width: 10, height: 10)
                                            .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))

                                        Text(prop.rawValue)
                                            .font(.system(size: 11, weight: isSel ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(isSel ? Color(hex: currentColor).opacity(0.25) : Color.secondary.opacity(0.08))
                                            .overlay(
                                                Capsule()
                                                    .stroke(isSel ? Color(hex: currentColor) : Color.clear, lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // 2. Swatches Palette for Selected Property
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Pick color for \(selectedProperty.rawValue):")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)

                            Spacer()

                            // Direct HEX input field
                            HStack(spacing: 3) {
                                Text("#").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                                TextField("HEX", text: bindingForProperty(selectedProperty))
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .frame(width: 58)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.12)))
                        }

                        // 16 Quick-Tap Swatches
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
                            ForEach(swatchPalette, id: \.self) { hex in
                                let isChosen = hexForProperty(selectedProperty).uppercased() == hex.uppercased()
                                Button(action: {
                                    setHexForProperty(selectedProperty, hex: hex)
                                }) {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: isChosen ? 2.5 : 0)
                                                .shadow(radius: isChosen ? 2 : 0)
                                        )
                                        .scaleEffect(isChosen ? 1.15 : 1.0)
                                }
                                .buttonStyle(.plain)
                                .help(hex)
                            }
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: themeManager.currentTheme.cardColor).opacity(0.45))
                    )

                    // 3. Live Preview Card
                    HStack(spacing: 8) {
                        Circle()
                            .stroke(Color(hex: accentHex), lineWidth: 3)
                            .frame(width: 28, height: 28)
                            .overlay(Text("⏱️").font(.system(size: 12)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Live Theme Preview")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: textHex))
                            Text("Primary: \(primaryHex) • Accent: \(accentHex)")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: textHex).opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: cardHex))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: accentHex).opacity(0.5), lineWidth: 1)
                            )
                    )

                    // 4. Save Buttons for Custom 1 & Custom 2
                    HStack(spacing: 10) {
                        Button(action: {
                            saveCustom(slot: 1)
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.arrow.down.fill").font(.system(size: 11))
                                Text("Save Custom 1").font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: accentHex))
                                    .opacity(isCustom1Hovered ? 0.9 : 1.0)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { isCustom1Hovered = $0 }

                        Button(action: {
                            saveCustom(slot: 2)
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.arrow.down.fill").font(.system(size: 11))
                                Text("Save Custom 2").font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: primaryHex))
                                    .opacity(isCustom2Hovered ? 0.9 : 1.0)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { isCustom2Hovered = $0 }
                    }

                    if let msg = saveSuccessMessage {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(msg)
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.green)
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadFromTheme(themeManager.currentTheme)
        }
    }

    // MARK: - Helpers

    private func hexForProperty(_ prop: ThemeColorProperty) -> String {
        switch prop {
        case .accent: return accentHex
        case .primary: return primaryHex
        case .card: return cardHex
        case .background: return backgroundHex
        case .text: return textHex
        case .highlight: return highlightHex
        }
    }

    private func setHexForProperty(_ prop: ThemeColorProperty, hex: String) {
        let clean = hex.hasPrefix("#") ? hex : "#\(hex)"
        switch prop {
        case .accent: accentHex = clean
        case .primary: primaryHex = clean
        case .card: cardHex = clean
        case .background: backgroundHex = clean
        case .text: textHex = clean
        case .highlight: highlightHex = clean
        }
    }

    private func bindingForProperty(_ prop: ThemeColorProperty) -> Binding<String> {
        Binding(
            get: {
                let h = hexForProperty(prop)
                return h.hasPrefix("#") ? String(h.dropFirst()) : h
            },
            set: { newVal in
                let clean = newVal.filter { $0.isLetter || $0.isNumber }
                setHexForProperty(prop, hex: "#\(clean)")
            }
        )
    }

    private func loadFromTheme(_ theme: AppTheme) {
        self.primaryHex = theme.primaryColor
        self.highlightHex = theme.highlightColor
        self.backgroundHex = theme.backgroundColor
        self.cardHex = theme.cardColor
        self.textHex = theme.textColor
        self.accentHex = theme.accentColor
    }

    private func saveCustom(slot: Int) {
        themeManager.saveCustomTheme(
            slot: slot,
            name: "Custom \(slot)",
            primaryColor: primaryHex,
            highlightColor: highlightHex,
            backgroundColor: backgroundHex,
            cardColor: cardHex,
            textColor: textHex,
            accentColor: accentHex
        )
        themeManager.selectTheme(id: "custom_\(slot)")

        withAnimation(.easeInOut(duration: 0.2)) {
            saveSuccessMessage = "Saved & Activated Custom \(slot)!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                saveSuccessMessage = nil
            }
        }
    }
}
