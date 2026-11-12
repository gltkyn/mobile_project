import SwiftUI

// Shared look for a diary entry in mixed lists (Agenda, Calendar),
// so a journal line is not drawn like an open todo.
extension DiaryEntry {
    var symbolName: String {
        switch kind {
        case .journal: return "book.closed"
        case .todo:    return isDone ? "checkmark.circle.fill" : "circle"
        case .done:    return "checkmark.circle.fill"
        }
    }

    var symbolColor: Color {
        switch kind {
        case .journal: return .secondary
        case .todo:    return isDone ? .green : .orange
        case .done:    return .green
        }
    }
}
