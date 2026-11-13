import Foundation

struct MachineResponse {
    let code: String
    let template: String
    let actionLabel: String
}

final class ResponseLibrary {
    static let shared = ResponseLibrary()
    
    // Keyed by each response's own `code`, so the key can never drift from it.
    private let responses: [String: MachineResponse]

    private init() {
        let all = [
            MachineResponse(
                code: "TASK_TIMED_SUGGESTION",
                template: "I noticed you want to '%@' on %@. Shall I lock this into your timed todos?",
                actionLabel: "Add Timed Todo"
            ),
            MachineResponse(
                code: "TASK_GENERAL_SUGGESTION",
                template: "Found an action item: '%@'. Would you like to add it to your list?",
                actionLabel: "Add to Todos"
            )
        ]
        self.responses = Dictionary(uniqueKeysWithValues: all.map { ($0.code, $0) })
    }

    func render(code: String, arguments: [CVarArg]) -> (text: String, actionLabel: String)? {
        guard let response = responses[code] else { return nil }
        let formattedText = String(format: response.template, arguments: arguments)
        return (formattedText, response.actionLabel)
    }
}
