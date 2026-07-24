import SwiftUI

struct CardDetailView: View {
    @State private var card: Card
    var columnID: UUID
    var boardID: UUID

    @EnvironmentObject private var store: TasklyStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var hasDueDate: Bool
    @State private var newLabelName = ""
    @State private var newLabelColor = CardLabel.paletteNames.first ?? "design"

    init(card: Card, columnID: UUID, boardID: UUID) {
        _card = State(initialValue: card)
        self.columnID = columnID
        self.boardID = boardID
        _hasDueDate = State(initialValue: card.dueDate != nil)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Titel", text: $card.title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)

                Toggle("Erledigt", isOn: $card.isCompleted)
                    .toggleStyle(.checkbox)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Beschreibung").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textSecondary)
                    TextEditor(text: $card.descriptionText)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .background(theme.background.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Labels").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textSecondary)
                    HStack(spacing: 6) {
                        ForEach(card.labels) { label in
                            HStack(spacing: 4) {
                                LabelChipView(label: label)
                                Button {
                                    card.labels.removeAll { $0.id == label.id }
                                } label: {
                                    Image(systemName: "xmark").font(.system(size: 9))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    HStack {
                        Picker("", selection: $newLabelColor) {
                            ForEach(CardLabel.paletteNames, id: \.self) { name in
                                Text(name.capitalized).tag(name)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                        TextField("Label-Name", text: $newLabelName)
                            .textFieldStyle(.roundedBorder)
                        Button("Hinzufügen") {
                            let trimmed = newLabelName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            card.labels.append(CardLabel(name: trimmed, colorName: newLabelColor))
                            newLabelName = ""
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Fälligkeitsdatum", isOn: $hasDueDate)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 12, weight: .semibold))
                    if hasDueDate {
                        DatePicker("", selection: Binding(
                            get: { card.dueDate ?? Date() },
                            set: { card.dueDate = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.field)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Checkliste").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textSecondary)
                        Spacer()
                        if let progress = card.checklistProgressText {
                            Text(progress).font(.system(size: 12)).foregroundStyle(theme.textSecondary)
                        }
                    }
                    ChecklistEditView(checklist: $card.checklist)
                }

                HStack {
                    Button(role: .destructive) {
                        store.deleteCard(card.id, in: boardID)
                        dismiss()
                    } label: {
                        Text("Karte löschen")
                    }
                    Spacer()
                    Button("Fertig") { dismiss() }
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(24)
        }
        .frame(width: 480, height: 560)
        .background(theme.background)
        .onChange(of: hasDueDate) { enabled in
            if !enabled { card.dueDate = nil }
        }
        .onChange(of: card) { newValue in
            store.updateCard(newValue, in: boardID)
        }
    }
}
