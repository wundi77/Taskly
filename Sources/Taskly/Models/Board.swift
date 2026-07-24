import Foundation

struct Board: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var order: Double
    var columns: [BoardColumn] = []
}
