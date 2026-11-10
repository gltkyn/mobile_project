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
        
        let entry = DiaryEntry(timestamp: Date(), content: trimmedText, isDone: isDoneValue)
        
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
}
