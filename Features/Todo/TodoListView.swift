import SwiftUI

struct TodoListView: View {
    @State private var todoEntries: [DiaryEntry] = []

    var body: some View {
        NavigationStack {
            List(todoEntries) { entry in
                HStack {
                    Button {
                        DiaryService.shared.updateEntryStatus(id: entry.id, isDone: true)
                        loadTodos()
                    } label: {
                        Image(systemName: "circle")
                    }
                    .buttonStyle(.plain)
                    Text(entry.content)
                    Spacer()
                    Text(entry.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("To-Do")
            .onAppear(perform: loadTodos)
        }
    }

    private func loadTodos() {
        todoEntries = DiaryService.shared.loadEntries().filter { !$0.isDone }
    }
}
