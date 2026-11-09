import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var entryText: String = ""
    @State private var statusMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    TextField("Write a diary entry (try 'todo add ...')", text: $entryText)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    Button(action: submitEntry) {
                        Image(systemName: "paperplane.fill")
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                
                if let statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("New Entry")
            .onAppear {
                LoggerService.shared.log("NAV: Opened DiaryView")
            }
        }
    }

    private func submitEntry() {
        let textToSave = entryText

        // In DiaryView submitEntry():
        let result = DiaryService.shared.saveEntry(text: textToSave)
        
        if result.success {
            entryText = ""
            var message = "Diary saved."
            
            if let auto = result.automatonResult, auto.matched, let title = auto.taskTitle {
                let newItem = Item(
                    timestamp: .now,
                    title: title,
                    priority: auto.priority ?? "Normal",
                    dueDate: auto.dueDate
                )
                modelContext.insert(newItem)
                message += " Added task with priority \(newItem.priority)!"
            }
            statusMessage = message
        } else {
            statusMessage = "Failed to save entry."
        }
    }
}
