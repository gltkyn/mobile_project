import SwiftUI

struct DailyView: View {
    @State private var dailyEntries: [DiaryEntry] = []

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Üst kısımda minimal yönlendirme ipucu (isteğe bağlı, aşağı kaydırarak dönmek için)
                HStack {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 16)
                
                Text("Günlük Rutinler")
                    .font(.largeTitle.bold())
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                
                if dailyEntries.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Henüz günlük rutin eklenmemiş.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Spacer()
                } else {
                    List {
                        ForEach($dailyEntries) { $entry in
                            HStack(spacing: 12) {
                                Button(action: {
                                    toggleDaily(entry: &entry)
                                }) {
                                    Image(systemName: entry.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(entry.isDone ? .green : .secondary)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                                
                                Text(entry.content)
                                    .font(.body)
                                    .strikethrough(entry.isDone, color: .secondary)
                                    .foregroundStyle(entry.isDone ? .secondary : .primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, 16)
                    .refreshable {
                        loadDailies()
                    }
                }
            }
        }
        .onAppear {
            loadDailies()
            LoggerService.shared.log("NAV: Opened DailyView")
        }
    }

    private func loadDailies() {
        // Tek ortak hafızadan isDaily == true olanları çekiyoruz
        dailyEntries = DiaryService.shared.loadEntries().filter { $0.isDaily }
    }

    private func toggleDaily(entry: inout DiaryEntry) {
        entry.isDone.toggle()
        // Servis üzerinden dosyadaki güncellemeyi kaydedebiliriz
        DiaryService.shared.updateEntryStatus(id: entry.id, isDone: entry.isDone)
    }
}
