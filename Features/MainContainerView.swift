import SwiftUI

enum HorizontalScreen: Int {
    case diary = 0 // Ana ekran ortada değil, solda veya tercih edilen akışta
    case todo = 1
    case done = 2
}

struct MainContainerView: View {
    // İstediğin gibi: Sol: Diary, Orta: Todo, Sağ: Done
    // İlk açılış Diary (0) ile başlar.
    @State private var horizontalScreen: HorizontalScreen = .diary
    @State private var showDaily: Bool = false // Yukarı kaydırma durumu (Daily ekranı)

    var body: some View {
        ZStack {
            // Yatay Kaydırma Katmanı (Diary <-> Todo <-> Done)
            TabView(selection: $horizontalScreen) {
                DiaryView()
                    .tag(HorizontalScreen.diary)
                
                TodoListView()
                    .tag(HorizontalScreen.todo)
                
                DoneListView()
                    .tag(HorizontalScreen.done)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Dikey Katman: Diary ekranındayken yukarı kaydırınca açılan Daily ekranı
            if showDaily {
                VStack {
                    DailyView()
                }
                .transition(.move(edge: .top))
                .zIndex(10)
            }
        }
        // Dikey Jest Algılayıcı (Diary üzerindeyken yukarı/aşağı kaydırma)
        .gesture(
            DragGesture().onEnded { value in
                if horizontalScreen == .diary {
                    if value.translation.height < -80 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDaily = true
                        }
                    } else if value.translation.height > 80 && showDaily {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDaily = false
                        }
                    }
                }
            }
        )
    }
}
