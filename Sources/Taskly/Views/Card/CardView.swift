import SwiftUI

struct CardView: View {
    var card: Card
    var columnID: UUID
    var boardID: UUID

    @EnvironmentObject private var store: TasklyStore
    @Environment(\.theme) private var theme

    @State private var isDropTargeted = false
    @State private var showDetail = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d. MMM"
        f.locale = Locale(identifier: "de_DE")
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            if !card.labels.isEmpty {
                HStack(spacing: 6) {
                    ForEach(card.labels) { label in
                        LabelChipView(label: label)
                    }
                }
            }

            Text(card.title)
                .font(.system(size: 14))
                .foregroundStyle(card.isCompleted ? theme.textSecondary : theme.textPrimary)
                .strikethrough(card.isCompleted)
                .lineLimit(3)

            HStack {
                if card.isOverdue {
                    Text("Überfällig")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.overdue)
                } else if let dueDate = card.dueDate {
                    Text(Self.dateFormatter.string(from: dueDate))
                        .font(.system(size: 12))
                        .foregroundStyle(theme.textSecondary)
                } else {
                    Spacer(minLength: 0)
                }

                Spacer(minLength: 8)

                if let progressText = card.checklistProgressText {
                    HStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(theme.textSecondary.opacity(0.25))
                                Capsule().fill(theme.primary)
                                    .frame(width: geo.size.width * card.checklistProgressFraction)
                            }
                        }
                        .frame(width: 60, height: 5)

                        Text(progressText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }
        }
        .padding(14)
        .background(theme.cardSurface)
        .opacity(card.isCompleted ? 0.8 : 1.0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isDropTargeted ? theme.primary : theme.cardBorder, lineWidth: isDropTargeted ? 2 : 1)
        )
        .shadow(color: .black.opacity(theme.isDark ? 0.25 : 0.06), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
        .draggable(CardTransferItem(cardID: card.id, sourceColumnID: columnID))
        .dropDestination(for: CardTransferItem.self) { items, _ in
            guard let item = items.first, item.cardID != card.id else { return false }
            store.moveCard(cardID: item.cardID, fromColumn: item.sourceColumnID, toColumn: columnID, beforeCardID: card.id, inBoard: boardID)
            return true
        } isTargeted: { targeted in
            isDropTargeted = targeted
        }
        .sheet(isPresented: $showDetail) {
            CardDetailView(card: card, columnID: columnID, boardID: boardID)
                .environmentObject(store)
        }
    }

}
