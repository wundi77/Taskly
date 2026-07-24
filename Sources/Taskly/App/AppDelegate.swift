import AppKit
import SwiftUI

/// Owns the menu bar status item and the single toggleable app window.
/// We manage the NSWindow manually (instead of a SwiftUI WindowGroup) so a
/// click on the status item can precisely show/hide one specific window.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var window: NSWindow?
    let store = TasklyStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Taskly")
            button.action = #selector(toggleWindow)
            button.target = self
        }
    }

    @objc func toggleWindow() {
        if let window, window.isVisible {
            window.close()
            return
        }
        showWindow()
    }

    private func showWindow() {
        if window == nil {
            let contentView = ContentView()
                .environmentObject(store)
            let hosting = NSHostingController(rootView: contentView)
            let newWindow = NSWindow(contentViewController: hosting)
            newWindow.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            newWindow.title = "Taskly"
            newWindow.setContentSize(NSSize(width: 1200, height: 800))
            newWindow.minSize = NSSize(width: 760, height: 480)
            newWindow.isReleasedWhenClosed = false
            newWindow.titlebarAppearsTransparent = true
            window = newWindow
        }
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
