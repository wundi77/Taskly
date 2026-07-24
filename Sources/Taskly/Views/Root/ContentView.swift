import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var store: TasklyStore
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @State private var searchText = ""
    @State private var editingBoardID: UUID?

    private var currentTheme: any Theme {
        isDarkMode ? DarkTheme() : LightTheme()
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                boards: store.boards,
                activeBoardID: $store.activeBoardID,
                editingBoardID: $editingBoardID,
                searchText: $searchText,
                isDarkMode: $isDarkMode,
                onAddBoard: createNewBoard
            )

            if let board = store.activeBoard {
                BoardView(board: board, searchText: searchText)
            } else {
                Spacer()
                Text("Kein Board vorhanden")
                    .foregroundStyle(currentTheme.textSecondary)
                Spacer()
            }
        }
        .background(
            ZStack {
                VisualEffectView(material: .underWindowBackground, isDark: currentTheme.isDark)
                currentTheme.background.opacity(0.75)
            }
        )
        .environment(\.theme, currentTheme)
        .frame(minWidth: 760, minHeight: 480)
        .onAppear { applyAppAppearance() }
        .onChange(of: isDarkMode) { _ in applyAppAppearance() }
    }

    private func createNewBoard() {
        let board = store.addBoard()
        editingBoardID = board.id
    }

    /// Native AppKit-backed controls (TextField input text, DatePicker, etc.)
    /// follow the app's effective appearance, not our custom `theme` colors.
    /// Forcing NSApp.appearance keeps them legible regardless of the system's
    /// own Light/Dark setting.
    private func applyAppAppearance() {
        NSApp.appearance = NSAppearance(named: isDarkMode ? .darkAqua : .aqua)
    }
}
