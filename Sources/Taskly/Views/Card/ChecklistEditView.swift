import SwiftUI

struct ChecklistEditView: View {
    @Binding var checklist: [ChecklistItem]
    @Environment(\.theme) private var theme

    @State private var newItemTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach($checklist) { $item in
                HStack(spacing: 8) {
                    Button {
                        item.isDone.toggle()
                    } label: {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isDone ? theme.primary : theme.textSecondary)
                    }
                    .buttonStyle(.plain)

                    TextField("", text: $item.title)
                        .textFieldStyle(.plain)
                        .strikethrough(item.isDone)
                        .foregroundStyle(item.isDone ? theme.textSecondary : theme.textPrimary)

                    Button {
                        checklist.removeAll { $0.id == item.id }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                TextField("Neuer Punkt…", text: $newItemTitle)
                    .textFieldStyle(.plain)
                    .onSubmit(addItem)
                Button("Hinzufügen", action: addItem)
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.primary)
                    .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addItem() {
        let trimmed = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklist.append(ChecklistItem(title: trimmed))
        newItemTitle = ""
    }
}
