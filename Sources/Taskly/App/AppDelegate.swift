import AppKit
import SwiftUI
import ServiceManagement

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
            button.action = #selector(handleStatusItemClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func handleStatusItemClick() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showStatusMenu()
        } else {
            toggleWindow()
        }
    }

    private func toggleWindow() {
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
            // No .titled: this removes the titlebar strip (traffic lights +
            // title) entirely so our own SwiftUI header starts right at the
            // window's top edge. Still .resizable so edges can be dragged.
            newWindow.styleMask = [.resizable, .fullSizeContentView]
            newWindow.title = "Taskly"
            newWindow.setContentSize(NSSize(width: 1200, height: 800))
            newWindow.minSize = NSSize(width: 760, height: 480)
            newWindow.isReleasedWhenClosed = false
            newWindow.isOpaque = false
            newWindow.backgroundColor = .clear
            // Without a titlebar there's no strip left to drag by, so the
            // whole window background becomes the drag handle.
            newWindow.isMovableByWindowBackground = true
            window = newWindow
        }
        window?.center()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func showStatusMenu() {
        let menu = NSMenu()

        let loginItem = NSMenuItem(title: "Beim Start automatisch laden", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Beenden", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.maxY + 4), in: button)
        }
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            // Best-effort: e.g. the user cancelled a system prompt. Nothing to recover here.
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
