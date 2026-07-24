import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TasklyStore
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @State private var searchText = ""

    private var currentTheme: any Theme {
        isDarkMode ? DarkTheme() : LightTheme()
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                boards: store.boards,
                activeBoardID: $store.activeBoardID,
                searchText: $searchText,
                isDarkMode: $isDarkMode,
                onAddTask: addTaskToFirstColumn
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
        .background(currentTheme.background)
        .environment(\.theme, currentTheme)
        .frame(minWidth: 760, minHeight: 480)
    }

    private func addTaskToFirstColumn() {
        guard let board = store.activeBoard, let firstColumn = board.columns.sorted(by: { $0.order < $1.order }).first else { return }
        store.addCard(title: "Neue Aufgabe", toColumn: firstColumn.id, inBoard: board.id)
    }
}
