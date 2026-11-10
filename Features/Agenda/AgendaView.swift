import SwiftUI

struct AgendaView: View {
    @State private var entries: [DiaryEntry] = []

    // Girdileri tarihlerine göre gruplayan yardımcı yapı
    private var groupedEntries: [(key: String, value: [DiaryEntry])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")

        // Tarih gün değerine göre gruplama yapıyoruz
        let grouped = Dictionary(grouping: entries) { entry in
            formatter.string(from: entry.timestamp)
        }

        // Kronolojik veya ters kronolojik sıralama için anahtarları sıralıyoruz
        return grouped.sorted { 
            // En yeni tarih en üstte olacak şekilde
            guard let date1 = formatter.date(from: $0.key),
                  let date2 = formatter.date(from: $1.key) else { return false }
            return date1 > date2
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "Ajanda Boş",
                        systemImage: "calendar.day.timeline.left",
                        description: Text("Kaydettiğiniz tüm notlar, todolar ve tamamlananlar burada kronolojik olarak akış şeklinde görünür.")
                    )
                } else {
                    List {
                        ForEach(groupedEntries, id: \.key) { dateString, dayEntries in
                            Section(header: Text(dateString).font(.headline).foregroundColor(.accentColor)) {
                                ForEach(dayEntries) { entry in
                                    HStack(alignment: .top, spacing: 10) {
                                        // Durum simgesi (Todo mu, Done mu, Normal günlük mü?)
                                        Image(systemName: iconFor(entry: entry))
                                            .foregroundColor(colorFor(entry: entry))
                                            .font(.subheadline)
                                            .padding(.top, 2)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.content)
                                                .font(.body)
                                                .strikethrough(entry.isDone, color: .gray)
                                            
                                            Text(entry.timestamp, style: .time)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        loadEntries()
                    }
                }
            }
            .navigationTitle("Ajanda")
            .onAppear(perform: loadEntries)
        }
    }

    private func loadEntries() {
        // Ortak kaynaktan verileri okuyoruz
        entries = DiaryService.shared.loadEntries()
    }

    // Girdinin durumuna göre ikon belirleme
    private func iconFor(entry: DiaryEntry) -> String {
        if entry.isDone {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }

    // Girdinin durumuna göre renk belirleme
    private func colorFor(entry: DiaryEntry) -> Color {
        if entry.isDone {
            return .green
        } else {
            return .orange
        }
    }
}
