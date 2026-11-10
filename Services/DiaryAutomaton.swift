import Foundation

enum ActionableIntent {
    case todo(title: String)
    case done(title: String)
    case journal
}

struct AutomatonResult {
    let matched: Bool
    let intent: ActionableIntent
    let title: String
}

final class DiaryAutomaton {
    static let shared = DiaryAutomaton()
    
    private init() {}

    /// Parses entry text to differentiate between todo items and done activities
    func process(text: String) -> AutomatonResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        // 1. Explicit Todo match (e.g., "todo add buy groceries")
        if lower.hasPrefix("todo add ") {
            let taskTitle = String(trimmed.dropFirst(9)).trimmingCharacters(in: .whitespacesAndNewlines)
            return AutomatonResult(matched: true, intent: .todo(title: taskTitle), title: taskTitle)
        }
        
        // 2. Completed activity triggers (e.g., "i biked today", "done biking", "did run 5k")
        let doneTriggers = ["i biked", "i ran", "i finished", "i completed", "done "]
        let isDoneActivity = doneTriggers.contains { lower.contains($0) }
        
        if isDoneActivity {
            return AutomatonResult(matched: true, intent: .done(title: trimmed), title: trimmed)
        }
        
        return AutomatonResult(matched: false, intent: .journal, title: trimmed)
    }
}
