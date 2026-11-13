import SwiftUI
import SwiftData

@main
struct ProjectApp: App {
    var body: some Scene {
        WindowGroup {
            MainContainerView()
        }
        .modelContainer(for: Item.self)
    }
}
