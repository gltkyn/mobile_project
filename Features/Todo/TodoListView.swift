import SwiftUI

struct TodoListView: View {
    @State private var todoEntries: [DiaryEntry] = []

    var body: some View {
        NavigationStack {
            List(todoEntries) { entry in
                HStack {
                    Image(systemName: "circle")
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
        todoEntries = DiaryService.shared.loadEntries().filter { $0.isOpenTodo }
    }
}
