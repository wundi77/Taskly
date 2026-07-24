import SwiftUI

/// Filled, pill-shaped primary button (e.g. the header's "+ Aufgabe" action).
struct PrimaryPillButton: View {
    var title: String
    var systemImage: String = "plus"
    var action: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(theme.primary)
        .foregroundStyle(theme.onPrimary)
        .clipShape(Capsule())
    }
}

/// Ghost-style pill/text button (e.g. "+ Karte hinzufügen", "+ Weitere Liste").
struct GhostButton: View {
    var title: String
    var systemImage: String = "plus"
    var action: () -> Void

    @Environment(\.theme) private var theme
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(theme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(isHovering ? theme.primary.opacity(0.12) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onHover { isHovering = $0 }
    }
}
