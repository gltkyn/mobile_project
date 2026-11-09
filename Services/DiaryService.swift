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

// Inside saveEntry return type:
@discardableResult
func saveEntry(text: String) -> (success: Bool, automatonResult: AutomatonResult?) {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else {
        LoggerService.shared.log("EVENT [Diary_Ignored]: Empty entry submission attempted.")
        return (false, nil)
    }
    
    let entry = DiaryEntry(timestamp: Date(), content: trimmedText)
    
    guard let data = try? JSONEncoder().encode(entry),
          let jsonString = String(data: data, encoding: .utf8) else {
        return (false, nil)
    }
    
    let ndjsonLine = jsonString + "\n"
    guard let lineData = ndjsonLine.data(using: .utf8) else { return (false, nil) }
    
    do {
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle.seekToEndOfFile()
        fileHandle.write(lineData)
        fileHandle.closeFile()
        
        let automatonResult = DiaryAutomaton.shared.process(text: trimmedText)
        return (true, automatonResult)
    } catch {
        return (false, nil)
    }
}

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
