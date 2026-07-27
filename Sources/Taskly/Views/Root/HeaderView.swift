import SwiftUI
import AppKit

struct HeaderView: View {
    var boards: [Board]
    @Binding var activeBoardID: UUID?
    @Binding var editingBoardID: UUID?
    @Binding var searchText: String
    @Binding var isDarkMode: Bool
    var onAddBoard: () -> Void

    @Environment(\.theme) private var theme

    private static let appIcon: NSImage = {
        if let path = Bundle.main.path(forResource: "AppIcon", ofType: "png"),
           let image = NSImage(contentsOfFile: path) {
            return image
        }
        return NSImage(systemSymbolName: "checkmark.square", accessibilityDescription: "Taskly") ?? NSImage()
    }()

    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(nsImage: Self.appIcon)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding(6)
                    .background(theme.textPrimary.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                Text("Taskly")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.primary)
            }

            BoardTabsView(boards: boards, activeBoardID: $activeBoardID, editingBoardID: $editingBoardID)

            Spacer()

            SearchFieldView(text: $searchText)

            themeSwitcher

            PrimaryPillButton(title: "Neues Board", action: onAddBoard)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            VisualEffectView(material: .headerView, isDark: theme.isDark, isWindowDraggable: true)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.headerBorder).frame(height: 1)
        }
    }

    private var themeSwitcher: some View {
        HStack(spacing: 2) {
            themeButton(title: "Dunkel", isActive: isDarkMode) { isDarkMode = true }
            themeButton(title: "Hell", isActive: !isDarkMode) { isDarkMode = false }
        }
        .padding(3)
        .background(theme.searchBackground)
        .clipShape(Capsule())
    }

    private func themeButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isActive ? theme.onPrimary : theme.textSecondary)
        }
        .buttonStyle(.plain)
        .background(isActive ? theme.primary : .clear)
        .clipShape(Capsule())
    }
}
