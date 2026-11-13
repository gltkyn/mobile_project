import Foundation

struct DiaryEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var content: String
    var isDone: Bool = false
    var isDaily: Bool = false
    var isTodo: Bool = false
}

// Tolerant decoding: lines written before a field existed (e.g. isDaily)
// still decode, using the default instead of being dropped.
// Kept in an extension so the memberwise initializer is preserved.
extension DiaryEntry {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        timestamp = try c.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        content = try c.decode(String.self, forKey: .content)
        isDone = try c.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
        isDaily = try c.decodeIfPresent(Bool.self, forKey: .isDaily) ?? false
        isTodo = try c.decodeIfPresent(Bool.self, forKey: .isTodo) ?? false
    }
}
