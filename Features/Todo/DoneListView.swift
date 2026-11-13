import SwiftUI

struct DoneListView: View {
    @State private var doneEntries: [DiaryEntry] = []

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Minimalist başlık (Standart NavigationBar yerine sade tipografi)
                Text("Yapılanlar")
                    .font(.largeTitle.bold())
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                
                if doneEntries.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Henüz tamamlanan bir şey yok.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Spacer()
                } else {
                    List(doneEntries) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.body)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.content)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(entry.timestamp, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .padding(.top, 16)
                    .refreshable {
                        loadDones()
                    }
                }
            }
        }
        .onAppear {
            loadDones()
            LoggerService.shared.log("NAV: Opened DoneListView (Minimalist)")
        }
    }

    private func loadDones() {
        // Tek ortak dosyadan okuyup isDone true olanları süzüyoruz
        doneEntries = DiaryService.shared.loadEntries().filter { $0.isDone }
    }
}
