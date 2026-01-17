
import SwiftUI

@main
struct Rubber_Band_HabitsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, Completion.self])//SwiftData time
    }
}
