import SwiftUI

struct BoardTabsView: View {
    var boards: [Board]
    @Binding var activeBoardID: UUID?

    @Environment(\.theme) private var theme

    private var sortedBoards: [Board] {
        boards.sorted { $0.order < $1.order }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(sortedBoards) { board in
                let isActive = board.id == activeBoardID
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
            }
        }
    }
}
