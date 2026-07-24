import SwiftUI
import AppKit

struct HeaderView: View {
    var boards: [Board]
    @Binding var activeBoardID: UUID?
    @Binding var searchText: String
    @Binding var isDarkMode: Bool
    var onAddTask: () -> Void

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
                    .frame(width: 26, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                Text("Taskly")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.primary)
            }

            BoardTabsView(boards: boards, activeBoardID: $activeBoardID)

            Spacer()

            SearchFieldView(text: $searchText)

            Picker("", selection: $isDarkMode) {
                Text("Dunkel").tag(true)
                Text("Hell").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 140)
            .labelsHidden()

            PrimaryPillButton(title: "Aufgabe", action: onAddTask)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            VisualEffectView(material: .headerView, isDark: theme.isDark)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.headerBorder).frame(height: 1)
        }
    }
}
