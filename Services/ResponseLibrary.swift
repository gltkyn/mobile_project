import Foundation

struct MachineResponse {
    let code: String
    let template: String
    let actionLabel: String
}

final class ResponseLibrary {
    static let shared = ResponseLibrary()
    
    private let responses: [String: MachineResponse] = [
        "task_timed_suggestion": MachineResponse(
            code: "TASK_TIMED_SUGGESTION",
            template: "I noticed you want to '%@' on %@. Shall I lock this into your timed todos?",
            actionLabel: "Add Timed Todo"
        ),
        "task_general_suggestion": MachineResponse(
            code: "TASK_GENERAL_SUGGESTION",
            template: "Found an action item: '%@'. Would you like to add it to your list?",
            actionLabel: "Add to Todos"
        )
    ]
    
    private init() {}

    func render(code: String, arguments: [CVarArg]) -> (text: String, actionLabel: String)? {
        guard let response = responses[code] else { return nil }
        let formattedText = String(format: response.template, arguments: arguments)
        return (formattedText, response.actionLabel)
    }
}
