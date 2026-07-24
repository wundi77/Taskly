import SwiftUI

struct AddColumnView: View {
    var boardID: UUID

    @EnvironmentObject private var store: TasklyStore
    @Environment(\.theme) private var theme

    @State private var isAdding = false
    @State private var title = ""

    var body: some View {
        VStack {
            if isAdding {
                VStack(spacing: 10) {
                    TextField("Titel der Liste…", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(commit)
                    HStack {
                        Button("Abbrechen") { isAdding = false; title = "" }
                        Button("Hinzufügen", action: commit)
                            .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(16)
            } else {
                Button {
                    isAdding = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                        Text("Weitere Liste")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(theme.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 220, height: 120)
        .background(theme.columnBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                .foregroundStyle(theme.textSecondary.opacity(0.3))
        )
    }

    private func commit() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addColumn(title: trimmed, toBoard: boardID)
        title = ""
        isAdding = false
    }
}
