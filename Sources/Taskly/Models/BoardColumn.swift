import Foundation

struct BoardColumn: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var order: Double
    var cards: [Card] = []
    /// Key into Theme.columnBadgeColors, e.g. "neutral" / "orange" / "green".
    var badgeColorName: String = "neutral"
}
