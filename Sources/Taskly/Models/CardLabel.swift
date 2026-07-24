import Foundation

/// A small colored tag shown on a card face (e.g. "Design", "Frontend", "QA").
/// `colorName` maps to a case in the current `Theme`'s label palette.
struct CardLabel: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var colorName: String

    static let paletteNames = ["design", "frontend", "qa", "bug", "content"]
}
