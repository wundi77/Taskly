import SwiftUI
import UniformTypeIdentifiers

struct ColumnView: View {
    var column: BoardColumn
    var boardID: UUID

    @EnvironmentObject private var store: TasklyStore
    @Environment(\.theme) private var theme

    @State private var isAddingCard = false
    @State private var newCardTitle = ""
    @State private var isRenamingColumn = false
    @State private var renameText = ""
    @State private var isDropTargeted = false

    private var sortedCards: [Card] {
        column.cards.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ZStack {
                // Guarantees a full-height drop target even when the column
                // has zero cards: an empty ScrollView's content (and with it
                // its droppable area) can otherwise collapse to nothing, so
                // dropping a card into an empty column silently failed.
                Color.clear

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(sortedCards) { card in
                            CardView(card: card, columnID: column.id, boardID: boardID)
                        }

                        if isAddingCard {
                            newCardField
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isDropTargeted ? theme.primary : .clear, lineWidth: 2)
            )
            .onDrop(of: [.tasklyCard], isTargeted: $isDropTargeted) { providers in
                CardTransferItem.from(providers: providers) { item in
                    guard let item else { return }
                    store.moveCard(cardID: item.cardID, fromColumn: item.sourceColumnID, toColumn: column.id, beforeCardID: nil, inBoard: boardID)
                }
                return true
            }

            if !isAddingCard {
                GhostButton(title: "weitere Karte") {
                    newCardTitle = ""
                    isAddingCard = true
                }
            }
        }
        .padding(10)
        .frame(width: 300)
        .background(theme.columnBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: 8) {
            if isRenamingColumn {
                TextField("Titel", text: $renameText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15, weight: .bold))
                    .onSubmit(commitRename)
            } else {
                Text(column.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
            }

            Text("\(column.cards.count)")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(theme.columnBadgeBackground(for: column.badgeColorName))
                .foregroundStyle(theme.columnBadgeForeground(for: column.badgeColorName))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Spacer()

            Menu {
                Button("Umbenennen") {
                    renameText = column.title
                    isRenamingColumn = true
                }
                Button("Löschen", role: .destructive) {
                    store.deleteColumn(column.id, in: boardID)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(theme.textSecondary)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 20)
        }
        .padding(.horizontal, 4)
    }

    private var newCardField: some View {
        TextField("Titel der Aufgabe…", text: $newCardTitle)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .padding(10)
            .background(theme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(theme.primary, lineWidth: 1.5)
            )
            .onSubmit(commitNewCard)
            .onExitCommand { isAddingCard = false }
    }

    private func commitNewCard() {
        let trimmed = newCardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.addCard(title: trimmed, toColumn: column.id, inBoard: boardID)
        }
        newCardTitle = ""
        isAddingCard = false
    }

    private func commitRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.renameColumn(column.id, in: boardID, to: trimmed)
        }
        isRenamingColumn = false
    }
}
