import Foundation

struct DiaryEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var content: String
}
