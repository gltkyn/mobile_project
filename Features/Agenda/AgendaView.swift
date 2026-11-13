import SwiftUI

struct AgendaView: View {
    @State private var entries: [DiaryEntry] = []

    // Created once; DateFormatter is expensive to build.
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()

    // Girdileri günlerine göre gruplar. Anahtar gerçek bir Date (günün başlangıcı),
    // böylece sıralama metin ayrıştırmaya bağlı kalmaz; biçimlendirme sadece gösterimde.
    private var groupedEntries: [(day: Date, entries: [DiaryEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        // En yeni gün en üstte
        return grouped
            .sorted { $0.key > $1.key }
            .map { (day: $0.key, entries: $0.value) }
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
                        ForEach(groupedEntries, id: \.day) { group in
                            Section(header: Text(Self.dayFormatter.string(from: group.day)).font(.headline).foregroundColor(.accentColor)) {
                                ForEach(group.entries) { entry in
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
