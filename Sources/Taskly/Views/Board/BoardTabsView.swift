import SwiftUI

struct BoardTabsView: View {
    var boards: [Board]
    @Binding var activeBoardID: UUID?
    @Binding var editingBoardID: UUID?

    @Environment(\.theme) private var theme
    @EnvironmentObject private var store: TasklyStore

    private var sortedBoards: [Board] {
        boards.sorted { $0.order < $1.order }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(sortedBoards) { board in
                let isActive = board.id == activeBoardID

                if editingBoardID == board.id {
                    BoardNameField(
                        name: board.name,
                        onCommit: { newName in
                            let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                store.renameBoard(board.id, to: trimmed)
                            }
                            editingBoardID = nil
                        }
                    )
                } else {
                    Button {
                        activeBoardID = board.id
                    } label: {
                        Text(board.name)
                            .font(.system(size: 13, weight: isActive ? .bold : .medium))
                            .foregroundStyle(isActive ? theme.primary : theme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isActive ? theme.primaryTinted : .clear)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Umbenennen") {
                            editingBoardID = board.id
                        }
                        Button("Board löschen", role: .destructive) {
                            store.deleteBoard(board.id)
                        }
                    }
                }
            }
        }
    }
}

/// Auto-focused text field used to name a freshly created board, right inside its tab slot.
/// Confirmed with Return only — no separate save/cancel buttons.
private struct BoardNameField: View {
    var name: String
    var onCommit: (String) -> Void

    @State private var text: String
    @FocusState private var isFocused: Bool
    @Environment(\.theme) private var theme

    init(name: String, onCommit: @escaping (String) -> Void) {
        self.name = name
        self.onCommit = onCommit
        _text = State(initialValue: name)
    }

    var body: some View {
        TextField("Board-Name", text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(theme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(minWidth: 120)
            .background(theme.primaryTinted)
            .clipShape(Capsule())
            .focused($isFocused)
            .onSubmit { onCommit(text) }
            .onAppear { isFocused = true }
    }
}
