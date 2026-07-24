import SwiftUI

@main
struct TasklyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // A SwiftUI App needs at least one Scene. Settings{} creates no
        // Dock/menu window on its own; combined with LSUIElement + the
        // .accessory activation policy set in AppDelegate this keeps
        // Taskly a pure menu-bar app with no unwanted extra windows.
        Settings {
            EmptyView()
        }
    }
}
