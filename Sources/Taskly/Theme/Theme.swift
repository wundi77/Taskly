import SwiftUI

/// Represents the full Taskly color palette for one appearance (dark or light).
/// We deliberately do NOT rely on the system color scheme — the app has its own
/// in-app "Dunkel"/"Hell" toggle driving one of these two concrete themes.
protocol Theme {
    var isDark: Bool { get }

    var background: Color { get }
    var headerBackground: Color { get }
    var headerBorder: Color { get }
    var columnBackground: Color { get }
    var cardSurface: Color { get }
    var cardBorder: Color { get }

    var primary: Color { get }
    var primaryTinted: Color { get }
    var onPrimary: Color { get }

    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var overdue: Color { get }

    var searchBackground: Color { get }
    var searchBorder: Color { get }

    func labelBackground(for colorName: String) -> Color
    func labelForeground(for colorName: String) -> Color
    func columnBadgeBackground(for colorName: String) -> Color
    func columnBadgeForeground(for colorName: String) -> Color
}

struct DarkTheme: Theme {
    let isDark = true

    let background = Color(hex: "232323")
    let headerBackground = Color(hex: "242424")
    let headerBorder = Color.white.opacity(0.08)
    let columnBackground = Color.white.opacity(0.04)
    let cardSurface = Color(hex: "1E1E1E")
    let cardBorder = Color.white.opacity(0.06)

    let primary = Color(hex: "008282")
    let primaryTinted = Color(hex: "008282").opacity(0.20)
    let onPrimary = Color.white

    let textPrimary = Color.white
    let textSecondary = Color.white.opacity(0.6)
    let overdue = Color(hex: "FF7043")

    let searchBackground = Color.white.opacity(0.06)
    let searchBorder = Color.white.opacity(0.12)

    private let labelPalette: [String: (Color, Color)] = [
        "design":   (Color(hex: "3A2E52"), Color(hex: "C9A9FF")),
        "frontend": (Color(hex: "1E3A4A"), Color(hex: "7FD1FF")),
        "qa":       (Color(hex: "1E3F3D"), Color(hex: "6FE0D3")),
        "bug":      (Color(hex: "4A1E1E"), Color(hex: "FF8A80")),
        "content":  (Color(hex: "4A3A1E"), Color(hex: "FFD180"))
    ]

    private let badgePalette: [String: (Color, Color)] = [
        "neutral": (Color.white.opacity(0.12), Color.white.opacity(0.75)),
        "orange":  (Color(hex: "4A2E12").opacity(0.8), Color(hex: "FFA766")),
        "green":   (Color(hex: "173B22").opacity(0.8), Color(hex: "6FDB8F"))
    ]

    func labelBackground(for colorName: String) -> Color { labelPalette[colorName]?.0 ?? Color.white.opacity(0.1) }
    func labelForeground(for colorName: String) -> Color { labelPalette[colorName]?.1 ?? Color.white }
    func columnBadgeBackground(for colorName: String) -> Color { badgePalette[colorName]?.0 ?? badgePalette["neutral"]!.0 }
    func columnBadgeForeground(for colorName: String) -> Color { badgePalette[colorName]?.1 ?? badgePalette["neutral"]!.1 }
}

struct LightTheme: Theme {
    let isDark = false

    let background = Color(hex: "FAF9F6")
    let headerBackground = Color.white.opacity(0.7)
    let headerBorder = Color.black.opacity(0.06)
    let columnBackground = Color.black.opacity(0.035)
    let cardSurface = Color.white
    let cardBorder = Color.black.opacity(0.05)

    let primary = Color(hex: "006767")
    let primaryTinted = Color(hex: "006767").opacity(0.12)
    let onPrimary = Color.white

    let textPrimary = Color.black.opacity(0.87)
    let textSecondary = Color.black.opacity(0.5)
    let overdue = Color(hex: "D84315")

    let searchBackground = Color.black.opacity(0.04)
    let searchBorder = Color.black.opacity(0.08)

    private let labelPalette: [String: (Color, Color)] = [
        "design":   (Color(hex: "EDE3FF"), Color(hex: "6A3FA0")),
        "frontend": (Color(hex: "DCEFFB"), Color(hex: "1F6FA8")),
        "qa":       (Color(hex: "DFF5F0"), Color(hex: "16806B")),
        "bug":      (Color(hex: "FDE1DE"), Color(hex: "B3261E")),
        "content":  (Color(hex: "FFF0D6"), Color(hex: "9A6A00"))
    ]

    private let badgePalette: [String: (Color, Color)] = [
        "neutral": (Color.black.opacity(0.08), Color.black.opacity(0.6)),
        "orange":  (Color(hex: "FFE4CC"), Color(hex: "B35B00")),
        "green":   (Color(hex: "D9F2DF"), Color(hex: "1F7A3D"))
    ]

    func labelBackground(for colorName: String) -> Color { labelPalette[colorName]?.0 ?? Color.black.opacity(0.06) }
    func labelForeground(for colorName: String) -> Color { labelPalette[colorName]?.1 ?? Color.black }
    func columnBadgeBackground(for colorName: String) -> Color { badgePalette[colorName]?.0 ?? badgePalette["neutral"]!.0 }
    func columnBadgeForeground(for colorName: String) -> Color { badgePalette[colorName]?.1 ?? badgePalette["neutral"]!.1 }
}
