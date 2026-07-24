import Foundation
import SwiftUI

@MainActor
final class TasklyStore: ObservableObject {
    @Published var boards: [Board] = []
    @Published var activeBoardID: UUID?

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let tasklyDir = appSupport.appendingPathComponent("Taskly", isDirectory: true)
        try? FileManager.default.createDirectory(at: tasklyDir, withIntermediateDirectories: true)
        fileURL = tasklyDir.appendingPathComponent("boards.json")
        load()
    }

    // MARK: - Persistence

    func load() {
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([Board].self, from: data), !decoded.isEmpty {
                boards = decoded.sorted { $0.order < $1.order }
                activeBoardID = boards.first?.id
                return
            }
        }
        boards = Self.sampleData()
        activeBoardID = boards.first?.id
        save()
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(boards) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Lookups

    var activeBoard: Board? {
        guard let activeBoardID else { return nil }
        return boards.first { $0.id == activeBoardID }
    }

    private func boardIndex(_ boardID: UUID) -> Int? {
        boards.firstIndex { $0.id == boardID }
    }

    private func columnIndex(boardIdx: Int, columnID: UUID) -> Int? {
        boards[boardIdx].columns.firstIndex { $0.id == columnID }
    }

    // MARK: - Boards

    @discardableResult
    func addBoard(name: String = "Neues Board") -> Board {
        let maxOrder = boards.map(\.order).max() ?? -1
        let board = Board(name: name, order: maxOrder + 1, columns: [])
        boards.append(board)
        activeBoardID = board.id
        save()
        return board
    }

    func renameBoard(_ boardID: UUID, to newName: String) {
        guard let bIdx = boardIndex(boardID) else { return }
        boards[bIdx].name = newName
        save()
    }

    // MARK: - Columns

    func addColumn(title: String, toBoard boardID: UUID) {
        guard let bIdx = boardIndex(boardID) else { return }
        let maxOrder = boards[bIdx].columns.map(\.order).max() ?? -1
        let column = BoardColumn(title: title, order: maxOrder + 1)
        boards[bIdx].columns.append(column)
        save()
    }

    func renameColumn(_ columnID: UUID, in boardID: UUID, to newTitle: String) {
        guard let bIdx = boardIndex(boardID), let cIdx = columnIndex(boardIdx: bIdx, columnID: columnID) else { return }
        boards[bIdx].columns[cIdx].title = newTitle
        save()
    }

    func deleteColumn(_ columnID: UUID, in boardID: UUID) {
        guard let bIdx = boardIndex(boardID) else { return }
        boards[bIdx].columns.removeAll { $0.id == columnID }
        save()
    }

    // MARK: - Cards

    func addCard(title: String, toColumn columnID: UUID, inBoard boardID: UUID) {
        guard let bIdx = boardIndex(boardID), let cIdx = columnIndex(boardIdx: bIdx, columnID: columnID) else { return }
        let maxOrder = boards[bIdx].columns[cIdx].cards.map(\.order).max() ?? -1
        let card = Card(title: title, order: maxOrder + 1)
        boards[bIdx].columns[cIdx].cards.append(card)
        save()
    }

    func updateCard(_ card: Card, in boardID: UUID) {
        guard let bIdx = boardIndex(boardID) else { return }
        for cIdx in boards[bIdx].columns.indices {
            if let cardIdx = boards[bIdx].columns[cIdx].cards.firstIndex(where: { $0.id == card.id }) {
                boards[bIdx].columns[cIdx].cards[cardIdx] = card
                save()
                return
            }
        }
    }

    func deleteCard(_ cardID: UUID, in boardID: UUID) {
        guard let bIdx = boardIndex(boardID) else { return }
        for cIdx in boards[bIdx].columns.indices {
            boards[bIdx].columns[cIdx].cards.removeAll { $0.id == cardID }
        }
        save()
    }

    /// Moves a card into (or within) a column, inserting it directly before
    /// `beforeCardID`, or at the end of the column if `beforeCardID` is nil.
    /// Recomputes only the moved card's fractional `order`; siblings are never renumbered.
    func moveCard(cardID: UUID, fromColumn sourceColumnID: UUID, toColumn destColumnID: UUID, beforeCardID: UUID?, inBoard boardID: UUID) {
        guard let bIdx = boardIndex(boardID) else { return }
        guard let srcColIdx = columnIndex(boardIdx: bIdx, columnID: sourceColumnID) else { return }
        guard let cardIdx = boards[bIdx].columns[srcColIdx].cards.firstIndex(where: { $0.id == cardID }) else { return }

        if sourceColumnID == destColumnID, cardID == beforeCardID { return }

        var card = boards[bIdx].columns[srcColIdx].cards.remove(at: cardIdx)

        guard let destColIdx = columnIndex(boardIdx: bIdx, columnID: destColumnID) else {
            // Destination vanished (shouldn't normally happen); put it back.
            boards[bIdx].columns[srcColIdx].cards.insert(card, at: cardIdx)
            return
        }

        let destCards = boards[bIdx].columns[destColIdx].cards.sorted { $0.order < $1.order }
        let insertAt: Int
        if let beforeCardID, let targetIdx = destCards.firstIndex(where: { $0.id == beforeCardID }) {
            insertAt = targetIdx
        } else {
            insertAt = destCards.count
        }

        let prevOrder = insertAt > 0 ? destCards[insertAt - 1].order : nil
        let nextOrder = insertAt < destCards.count ? destCards[insertAt].order : nil

        switch (prevOrder, nextOrder) {
        case let (.some(p), .some(n)):
            card.order = (p + n) / 2
        case let (.some(p), .none):
            card.order = p + 1
        case let (.none, .some(n)):
            card.order = n - 1
        case (.none, .none):
            card.order = 0
        }

        boards[bIdx].columns[destColIdx].cards.append(card)
        boards[bIdx].columns[destColIdx].cards.sort { $0.order < $1.order }
        save()
    }

    // MARK: - Sample data (first launch seed)

    static func sampleData() -> [Board] {
        let today = Calendar.current.startOfDay(for: Date())
        func daysAgo(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: -n, to: today)! }
        func daysFromNow(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: n, to: today)! }

        func label(_ name: String, _ color: String) -> CardLabel { CardLabel(name: name, colorName: color) }

        let inProgress = BoardColumn(title: "In Bearbeitung", order: 0, cards: [
            Card(title: "Wireframes Startseite", labels: [label("Design", "design")],
                 dueDate: daysFromNow(21), checklist: [
                    ChecklistItem(title: "Header", isDone: true),
                    ChecklistItem(title: "Hero", isDone: true),
                    ChecklistItem(title: "Footer", isDone: false),
                    ChecklistItem(title: "Nav", isDone: false),
                    ChecklistItem(title: "Sidebar", isDone: false)
                 ], order: 0),
            Card(title: "Design-System Farben & Typo", labels: [label("Design", "design")],
                 dueDate: daysFromNow(23), checklist: [
                    ChecklistItem(title: "Farben", isDone: true),
                    ChecklistItem(title: "Typo", isDone: true),
                    ChecklistItem(title: "Spacing", isDone: true),
                    ChecklistItem(title: "Review", isDone: false)
                 ], order: 1),
            Card(title: "Responsive Breakpoints definieren", labels: [label("Frontend", "frontend")],
                 dueDate: daysFromNow(25), checklist: [
                    ChecklistItem(title: "Mobile", isDone: true),
                    ChecklistItem(title: "Tablet", isDone: false),
                    ChecklistItem(title: "Desktop", isDone: false)
                 ], order: 2)
        ], badgeColorName: "neutral")

        let review = BoardColumn(title: "Review", order: 1, cards: [
            Card(title: "Navigation-Komponente prüfen", labels: [label("Frontend", "frontend"), label("QA", "qa")],
                 dueDate: daysAgo(2), checklist: [
                    ChecklistItem(title: "Desktop", isDone: true),
                    ChecklistItem(title: "Mobile", isDone: true),
                    ChecklistItem(title: "A11y", isDone: true)
                 ], order: 0),
            Card(title: "Formular-Validierung testen", labels: [label("Bug", "bug")],
                 dueDate: daysFromNow(27), checklist: [
                    ChecklistItem(title: "E-Mail-Feld", isDone: true),
                    ChecklistItem(title: "Passwort-Feld", isDone: false),
                    ChecklistItem(title: "Pflichtfelder", isDone: false),
                    ChecklistItem(title: "Fehlermeldungen", isDone: false)
                 ], order: 1)
        ], badgeColorName: "orange")

        let done = BoardColumn(title: "Fertig", order: 2, cards: [
            Card(title: "Performance-Audit Startseite", labels: [label("QA", "qa")],
                 dueDate: daysAgo(22), checklist: [
                    ChecklistItem(title: "Lighthouse", isDone: true),
                    ChecklistItem(title: "Bilder optimiert", isDone: true),
                    ChecklistItem(title: "Caching", isDone: true)
                 ], isCompleted: true, order: 0),
            Card(title: "Logo & Favicon aktualisieren", labels: [label("Design", "design")],
                 dueDate: daysAgo(23), checklist: [
                    ChecklistItem(title: "Logo", isDone: true),
                    ChecklistItem(title: "Favicon", isDone: true)
                 ], isCompleted: true, order: 1),
            Card(title: "Launch-Checkliste vorbereiten", labels: [label("Content", "content")],
                 dueDate: daysAgo(27), checklist: [
                    ChecklistItem(title: "Texte", isDone: true),
                    ChecklistItem(title: "SEO", isDone: true),
                    ChecklistItem(title: "Redirects", isDone: true),
                    ChecklistItem(title: "Analytics", isDone: true),
                    ChecklistItem(title: "Freigabe", isDone: true)
                 ], isCompleted: true, order: 2)
        ], badgeColorName: "green")

        let websiteRelaunch = Board(name: "Website Relaunch", order: 0, columns: [inProgress, review, done])
        let marketing = Board(name: "Marketing Kampagne", order: 1, columns: [
            BoardColumn(title: "Ideen", order: 0, cards: [], badgeColorName: "neutral"),
            BoardColumn(title: "In Arbeit", order: 1, cards: [], badgeColorName: "neutral"),
            BoardColumn(title: "Veröffentlicht", order: 2, cards: [], badgeColorName: "green")
        ])
        let mobileApp = Board(name: "Mobile App", order: 2, columns: [
            BoardColumn(title: "Backlog", order: 0, cards: [], badgeColorName: "neutral"),
            BoardColumn(title: "In Bearbeitung", order: 1, cards: [], badgeColorName: "neutral"),
            BoardColumn(title: "Fertig", order: 2, cards: [], badgeColorName: "green")
        ])

        return [websiteRelaunch, marketing, mobileApp]
    }
}
