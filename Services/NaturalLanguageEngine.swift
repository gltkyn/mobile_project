import Foundation
import NaturalLanguage

struct StructuredDiaryIntent {
    let rawText: String
    let detectedIntent: SystemIntent
    let extractedPayload: String?
    let targetDate: Date?
}

enum SystemIntent {
    case createTask
    case scheduleReminder
    case queryLibrary
    case generalJournal
}

final class NaturalLanguageEngine {
    static let shared = NaturalLanguageEngine()
    
    private init() {}

    /// Deeply analyzes raw diary text to extract intents, payloads, and calendar references
    func analyze(_ text: String) -> StructuredDiaryIntent {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Extract dates using Foundation's native Data Detector
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let matches = detector?.matches(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed))
        
        var targetDate: Date? = nil
        var dateRange: Range<String.Index>? = nil
        
        if let match = matches?.first, let date = match.date {
            targetDate = date
            if let swiftRange = Range(match.range, in: trimmed) {
                dateRange = swiftRange
            }
        }
        
        // 2. Perform Linguistic Analysis via NLTagger
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = trimmed
        
        var actionVerbFound = false
        var payloadWords: [String] = []
        
        // Root action verbs that map to utility triggers
        let actionTriggers = ["bake", "buy", "call", "schedule", "finish", "submit", "make", "clean", "write"]
        
        tagger.enumerateTags(in: trimmed.startIndex..<trimmed.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            let word = String(trimmed[range]).lowercased()
            let lemma = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lemma).0?.rawValue.lowercased() ?? word
            
            if actionTriggers.contains(lemma) || actionTriggers.contains(word) {
                actionVerbFound = true
                payloadWords.append(String(trimmed[range]))
            } else if actionVerbFound {
                // Exclude the date substring from becoming part of the task title
                if let dr = dateRange, dr.overlaps(range) { return true }
                payloadWords.append(String(trimmed[range]))
            }
            return true
        }
        
        let payload = payloadWords.isEmpty ? nil : payloadWords.joined(separator: " ").capitalized
        let intent: SystemIntent = (payload != nil) ? .createTask : .generalJournal
        
        LoggerService.shared.log("NL_ENGINE: Parsed intent -> \(intent), Payload: \"\(payload ?? "None")\", Date: \(String(describing: targetDate))")
        
        return StructuredDiaryIntent(
            rawText: trimmed,
            detectedIntent: intent,
            extractedPayload: payload,
            targetDate: targetDate
        )
    }
}
