import Foundation

enum AutomatonState {
    case idle
    case scanning
    case matchFound(task: String, priority: String?, dueDate: String?)
    case failed
}

struct AutomatonResult {
    let matched: Bool
    let taskTitle: String?
    let priority: String?
    let dueDate: String?
}

final class DiaryAutomaton {
    static let shared = DiaryAutomaton()
    
    private(set) var currentState: AutomatonState = .idle
    
    private init() {}

    /// Parses text for: "todo add [task] [#priority] [due:date]"
    func process(text: String) -> AutomatonResult {
        updateState(.scanning)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Regex breakdown:
        // Group 1: Task text
        // Group 2: Optional priority tag (#high, #medium, #low)
        // Group 3: Optional due date (due:something)
        let pattern = #"(?i)\btodo\s+add\s+(.+?)(?:\s+#(high|medium|low))?(?:\s+due:([^\s]+))?$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              let taskRange = Range(match.range(at: 1), in: trimmed) else {
            updateState(.failed)
            return AutomatonResult(matched: false, taskTitle: nil, priority: nil, dueDate: nil)
        }
        
        let taskTitle = String(trimmed[taskRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract optional priority (Group 2)
        var priority: String? = nil
        if match.range(at: 2).location != NSNotFound,
           let priorityRange = Range(match.range(at: 2), in: trimmed) {
            priority = String(trimmed[priorityRange]).capitalized
        }
        
        // Extract optional due date (Group 3)
        var dueDate: String? = nil
        if match.range(at: 3).location != NSNotFound,
           let dueRange = Range(match.range(at: 3), in: trimmed) {
            dueDate = String(trimmed[dueRange])
        }
        
        guard !taskTitle.isEmpty else {
            updateState(.failed)
            return AutomatonResult(matched: false, taskTitle: nil, priority: nil, dueDate: nil)
        }
        
        updateState(.matchFound(task: taskTitle, priority: priority, dueDate: dueDate))
        LoggerService.shared.log("AUTOMATON: Matched task=\"\(taskTitle)\" | Priority=\(priority ?? "None") | Due=\(dueDate ?? "None")")
        
        updateState(.idle)
        return AutomatonResult(matched: true, taskTitle: taskTitle, priority: priority, dueDate: dueDate)
    }
    
    private func updateState(_ newState: AutomatonState) {
        self.currentState = newState
    }
}
