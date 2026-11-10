import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var allEntries: [DiaryEntry] = []

    // Seçili güne ait girdileri filtreler
    private var filteredEntries: [DiaryEntry] {
        let calendar = Calendar.current
        return allEntries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Grafiksel Takvim Seçici
                DatePicker(
                    "Tarih Seçin",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .onChange(of: selectedDate) { _ in
                    loadEntries()
                }

                Divider()

                // Seçilen Güne Ait Girdiler Listesi
                if filteredEntries.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Bu tarihe ait hiçbir kayıt bulunamadı.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List(filteredEntries) { entry in
                        HStack(alignment: .top, spacing: 12) {
                            // Durum İkonu (Yapıldı / Yapılacak / Günlük)
                            Image(systemName: entry.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(entry.isDone ? .green : .orange)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.content)
                                    .font(.body)
                                    .strikethrough(entry.isDone, color: .gray)
                                
                                Text(entry.timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Takvim")
            .onAppear(perform: loadEntries)
        }
    }

    private func loadEntries() {
        // Tek veri kaynağından tüm girdileri yükler
        allEntries = DiaryService.shared.loadEntries()
    }
}
