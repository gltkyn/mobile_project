import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.timestamp, format: .dateTime.month().day().hour().minute().second())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onAppear {
                LoggerService.shared.log("NAV: Opened TodoListView")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
                LoggerService.shared.log("ACTION: Deleted todo item")
            }
        }
    }
}
