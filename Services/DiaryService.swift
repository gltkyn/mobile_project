import Foundation

final class DiaryService {
    static let shared = DiaryService()
    private let fileURL: URL

    private init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsURL.appendingPathComponent("diary.ndjson")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
    }

    /// Saves entry to single NDJSON file set with isDone flag
    @discardableResult
    func saveEntry(text: String, explicitIsDone: Bool? = nil) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return false }
        
        // Determine if it is marked done via parameter or auto-parsed intent
        let automatonResult = DiaryAutomaton.shared.process(text: trimmedText)
        let isDoneValue: Bool
        
        if let explicit = explicitIsDone {
            isDoneValue = explicit
        } else {
            switch automatonResult.intent {
            case .done:
                isDoneValue = true
            default:
                isDoneValue = false
            }
        }
        
        var isTodoValue = false
        if case .todo = automatonResult.intent { isTodoValue = true }

        let entry = DiaryEntry(timestamp: Date(), content: automatonResult.title.isEmpty ? trimmedText : automatonResult.title, isDone: isDoneValue, isTodo: isTodoValue)
        
        guard let data = try? JSONEncoder().encode(entry),
              let jsonString = String(data: data, encoding: .utf8) else { return false }
        
        let ndjsonLine = jsonString + "\n"
        guard let lineData = ndjsonLine.data(using: .utf8) else { return false }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(lineData)
            fileHandle.closeFile()
            return true
        } catch {
            return false
        }
    }

    /// Reads all entries from the single storage file
    func loadEntries() -> [DiaryEntry] {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return [] }
        let lines = content.components(separatedBy: .newlines)
        
        var entries: [DiaryEntry] = []
        let decoder = JSONDecoder()
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, let data = trimmed.data(using: .utf8) else { continue }
            
            if let entry = try? decoder.decode(DiaryEntry.self, from: data) {
                entries.append(entry)
            }
        }
        return entries.reversed()
    }

    /// Updates the isDone flag of one entry by rewriting the file atomically.
    /// Every other line is kept exactly as it was, including lines that
    /// fail to decode, so an update can never silently delete data.
    @discardableResult
    func updateEntryStatus(id: UUID, isDone: Bool) -> Bool {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return false }

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        var outputLines: [String] = []
        var found = false

        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if !found,
               let data = trimmed.data(using: .utf8),
               var entry = try? decoder.decode(DiaryEntry.self, from: data),
               entry.id == id {
                entry.isDone = isDone
                if let newData = try? encoder.encode(entry),
                   let newLine = String(data: newData, encoding: .utf8) {
                    outputLines.append(newLine)
                    found = true
                    continue
                }
            }
            outputLines.append(trimmed)
        }

        guard found else { return false }

        do {
            try (outputLines.joined(separator: "\n") + "\n")
                .write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
