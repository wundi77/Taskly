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
            VStack(alignment: .leading, spacing: 22) {
                TextField("Titel", text: $card.title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                    .padding(10)
                    .background(theme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )

                checkRow(title: "Erledigt", isOn: $card.isCompleted)

                sectionLabel("Beschreibung")
                TextEditor(text: $card.descriptionText)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textPrimary)
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .padding(6)
                    .background(theme.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(theme.cardBorder, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("Labels")
                    if !card.labels.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(card.labels) { label in
                                HStack(spacing: 4) {
                                    LabelChipView(label: label)
                                    Button {
                                        card.labels.removeAll { $0.id == label.id }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            ForEach(CardLabel.paletteNames, id: \.self) { name in
                                colorSwatch(name)
                            }
                        }

                        TextField("Label-Name", text: $newLabelName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundStyle(theme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(theme.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(theme.cardBorder, lineWidth: 1)
                            )
                            .onSubmit(addLabel)

                        Button("Hinzufügen", action: addLabel)
                            .buttonStyle(.plain)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.onPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    checkRow(title: "Fälligkeitsdatum", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("", selection: Binding(
                            get: { card.dueDate ?? Date() },
                            set: { card.dueDate = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.field)
                        .padding(8)
                        .background(theme.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(theme.cardBorder, lineWidth: 1)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        sectionLabel("Checkliste")
                        Spacer()
                        if let progress = card.checklistProgressText {
                            Text(progress).font(.system(size: 12)).foregroundStyle(theme.textSecondary)
                        }
                    }
                    ChecklistEditView(checklist: $card.checklist)
                }

                Rectangle().fill(theme.cardBorder).frame(height: 1)

                HStack {
                    Button {
                        store.deleteCard(card.id, in: boardID)
                        dismiss()
                    } label: {
                        Text("Karte löschen")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.overdue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(theme.overdue, lineWidth: 1.5)
                    )

                    Spacer()

                    PrimaryPillButton(title: "Fertig", systemImage: "checkmark") { dismiss() }
                }
            }
            .padding(24)
        }
        .frame(width: 480, height: 620)
        .background(theme.background)
        .onChange(of: hasDueDate) { enabled in
            if !enabled { card.dueDate = nil }
        }
        .onChange(of: card) { newValue in
            store.updateCard(newValue, in: boardID)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(theme.textSecondary)
    }

    private func checkRow(title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn.wrappedValue ? theme.primary : theme.textSecondary)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }

    private func colorSwatch(_ name: String) -> some View {
        Circle()
            .fill(theme.labelForeground(for: name))
            .frame(width: 20, height: 20)
            .overlay(
                Circle().stroke(theme.textPrimary, lineWidth: newLabelColor == name ? 2 : 0)
            )
            .overlay(
                Circle().stroke(theme.cardBorder, lineWidth: 1)
            )
            .onTapGesture { newLabelColor = name }
    }

    private func addLabel() {
        let trimmed = newLabelName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        card.labels.append(CardLabel(name: trimmed, colorName: newLabelColor))
        newLabelName = ""
    }
}
