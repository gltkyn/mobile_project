import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var priority: String
    var dueDate: String?

    init(timestamp: Date = .now, title: String, priority: String = "Normal", dueDate: String? = nil) {
        self.timestamp = timestamp
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
    }
}
