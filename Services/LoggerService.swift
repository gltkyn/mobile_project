import Foundation

final class LoggerService {
    static let shared = LoggerService()
    
    private let logFileURL: URL
    private let dateFormatter: DateFormatter

    private init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.logFileURL = documentsURL.appendingPathComponent(".app.log")
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }
    }

    func log(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logLine = "[\(timestamp)] \(message)\n"
        
        guard let data = logLine.data(using: .utf8) else { return }
        
        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }
        
        #if DEBUG
        print(logLine, terminator: "")
        #endif
    }
}
