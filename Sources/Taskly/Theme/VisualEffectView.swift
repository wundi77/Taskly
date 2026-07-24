import SwiftUI
import AppKit

/// Bridges NSVisualEffectView into SwiftUI for the translucent "glass" header bar.
/// The appearance is forced explicitly (rather than left to follow the system
/// setting) so the blur tint matches Taskly's own in-app Dunkel/Hell theme even
/// if the Mac itself is set to the opposite system appearance.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .headerView
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    var isDark: Bool = true

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    }
}
