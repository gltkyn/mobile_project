import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
            
            DiaryHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            TodoListView()
                .tabItem {
                    Label("Todos", systemImage: "checklist")
                }
        }
    }
}
