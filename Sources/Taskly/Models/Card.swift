import Foundation

struct Card: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var descriptionText: String = ""
    var labels: [CardLabel] = []
    var dueDate: Date? = nil
    var checklist: [ChecklistItem] = []
    var isCompleted: Bool = false
    /// Fractional ordering key used for drag-and-drop reordering.
    /// Recompute as the midpoint of two neighbors when inserting; never renumber siblings.
    var order: Double

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }

    var checklistProgressText: String? {
        guard !checklist.isEmpty else { return nil }
        return "\(checklist.filter(\.isDone).count)/\(checklist.count)"
    }

    var checklistProgressFraction: Double {
        guard !checklist.isEmpty else { return 0 }
        return Double(checklist.filter(\.isDone).count) / Double(checklist.count)
    }
}
