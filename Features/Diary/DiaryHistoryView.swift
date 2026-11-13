import SwiftUI

struct DiaryHistoryView: View {
    @State private var entries: [DiaryEntry] = []

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Found",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Your diary.ndjson file is currently empty.")
                    )
                } else {
                    List(entries) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.timestamp, format: .dateTime.year().month().day().hour().minute().second())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text(entry.content)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        loadEntries()
                    }
                }
            }
            .navigationTitle("Diary History")
            .onAppear {
                loadEntries()
            }
        }
    }

    private func loadEntries() {
        entries = DiaryService.shared.loadEntries()
        LoggerService.shared.log("NAV: Loaded \(entries.count) entries from diary.ndjson")
    }
}
