import Foundation

struct DiaryEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var content: String
    var isDone: Bool = false
    var isDaily: Bool = false // Yeni eklenen günlük rutin bayrağı
}
