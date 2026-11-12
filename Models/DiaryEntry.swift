import Foundation

/// What a diary line *is*. Replaces the old rule "isDone == false means todo",
/// which made every plain journal line show up in To-Do.
enum EntryKind: String, Codable {
    case journal   // plain diary line: only Diary history, Agenda and Calendar
    case todo      // something to do: To-Do while open, Done once completed
    case done      // something already done: Done list
}

struct DiaryEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var content: String
    var kind: EntryKind = .journal
    var isDone: Bool = false
    var isDaily: Bool = false // Yeni eklenen günlük rutin bayrağı
}

// Tolerant decoding: lines written before a field existed (e.g. isDaily, kind)
// still decode, using a default instead of being dropped.
// Kept in an extension so the memberwise initializer is preserved.
extension DiaryEntry {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let decodedContent = try c.decode(String.self, forKey: .content)
        let decodedIsDone = try c.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
        let decodedIsDaily = try c.decodeIfPresent(Bool.self, forKey: .isDaily) ?? false

        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        timestamp = try c.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        content = decodedContent
        isDone = decodedIsDone
        isDaily = decodedIsDaily

        // Lines saved before `kind` existed have none: infer it once, here.
        if let stored = try? c.decodeIfPresent(EntryKind.self, forKey: .kind) {
            kind = stored
        } else {
            kind = Self.legacyKind(content: decodedContent, isDone: decodedIsDone, isDaily: decodedIsDaily)
        }
    }

    /// Before `kind`, a todo could only come from the explicit "todo add ..." prefix
    /// (or the daily-routine flag), and a done entry was just isDone == true.
    private static func legacyKind(content: String, isDone: Bool, isDaily: Bool) -> EntryKind {
        if isDaily || content.lowercased().hasPrefix("todo add ") { return .todo }
        return isDone ? .done : .journal
    }
}

// The single place that decides which list an entry belongs to.
extension DiaryEntry {
    /// Shown in To-Do.
    var isOpenTodo: Bool { kind == .todo && !isDone }

    /// Shown in Done (finished todos and logged "I did X" entries, never journal lines).
    var isCompleted: Bool { kind != .journal && isDone }
}
