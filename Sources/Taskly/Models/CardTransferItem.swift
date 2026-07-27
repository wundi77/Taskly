import Foundation
import UniformTypeIdentifiers

extension UTType {
    static var tasklyCard = UTType(exportedAs: "com.wunderwald.taskly.card")
}

/// Drag payload carrying just enough information (card + source column id)
/// to let a drop target move the card via TasklyStore.moveCard(...).
///
/// Uses the classic NSItemProvider-based .onDrag/.onDrop instead of the
/// newer Transferable/.draggable/.dropDestination API: the newer API only
/// reliably resolved drops within the same source container (reordering
/// inside one column worked) but silently failed to register drops on a
/// sibling column's ScrollView (moving a card to a different column did
/// nothing) — a known rough edge of dropDestination across independent
/// scroll containers on macOS. onDrag/onDrop's hit-testing is older and
/// more consistently reliable across arbitrary view hierarchies.
struct CardTransferItem: Codable {
    var cardID: UUID
    var sourceColumnID: UUID

    func toItemProvider() -> NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: UTType.tasklyCard.identifier, visibility: .all) { completion in
            let data = try? JSONEncoder().encode(self)
            completion(data, nil)
            return nil
        }
        return provider
    }

    static func from(providers: [NSItemProvider], completion: @escaping (CardTransferItem?) -> Void) {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.tasklyCard.identifier) }) else {
            completion(nil)
            return
        }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.tasklyCard.identifier) { data, _ in
            let item = data.flatMap { try? JSONDecoder().decode(CardTransferItem.self, from: $0) }
            DispatchQueue.main.async {
                completion(item)
            }
        }
    }
}
