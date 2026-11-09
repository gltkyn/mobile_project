import SwiftUI
import SwiftData

@main
struct ProjectApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Item.self)
    }
}
