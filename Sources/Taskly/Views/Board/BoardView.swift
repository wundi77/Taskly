import SwiftUI

struct BoardView: View {
    var board: Board
    var searchText: String

    @Environment(\.theme) private var theme

    private var sortedColumns: [BoardColumn] {
        board.columns.sorted { $0.order < $1.order }
    }

    private func filteredColumn(_ column: BoardColumn) -> BoardColumn {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return column }
        var filtered = column
        filtered.cards = column.cards.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
        return filtered
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(sortedColumns) { column in
                    ColumnView(column: filteredColumn(column), boardID: board.id)
                }
                AddColumnView(boardID: board.id)
            }
            .padding(20)
        }
        .background(theme.background)
    }
}
