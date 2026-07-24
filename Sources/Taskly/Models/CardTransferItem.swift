import Foundation
import CoreTransferable
import UniformTypeIdentifiers

extension UTType {
    static var tasklyCard = UTType(exportedAs: "com.wunderwald.taskly.card")
}

/// Drag payload carrying just enough information (card + source column id)
/// to let a drop target move the card via TasklyStore.moveCard(...).
struct CardTransferItem: Codable, Transferable {
    var cardID: UUID
    var sourceColumnID: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .tasklyCard)
    }
}
