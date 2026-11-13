import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
            
            TodoListView()
                .tabItem {
                    Label("To-Do", systemImage: "checkmark.square")
                }
            
            DoneListView()
                .tabItem {
                    Label("Done", systemImage: "checkmark.seal.fill")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            AgendaView()
                .tabItem {
                    Label("Agenda", systemImage: "calendar.day.timeline.left")
                }
        }
    }
}
