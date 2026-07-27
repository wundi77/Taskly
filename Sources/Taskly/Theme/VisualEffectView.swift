import SwiftUI
import AppKit

/// NSVisualEffectView subclass that can optionally act as a window-drag handle.
/// Combining both behaviors in one native view avoids z-order ambiguity that
/// would arise from stacking two separate overlapping NSViewRepresentables
/// (whichever one is "on top" for AppKit hit-testing would swallow the
/// other's mouseDown).
final class DraggableVisualEffectView: NSVisualEffectView {
    var isWindowDraggable = false

    override func mouseDown(with event: NSEvent) {
        if isWindowDraggable {
            window?.performDrag(with: event)
        } else {
            super.mouseDown(with: event)
        }
    }
}

/// Bridges NSVisualEffectView into SwiftUI for the translucent "glass" header bar.
/// The appearance is forced explicitly (rather than left to follow the system
/// setting) so the blur tint matches Taskly's own in-app Dunkel/Hell theme even
/// if the Mac itself is set to the opposite system appearance.
///
/// `isWindowDraggable` should only be set for the header background: since the
/// app window has no titlebar, clicking empty header space is the only way
/// left to drag the window. It must stay off elsewhere (e.g. behind the
/// board/card area), since that would swallow the mouse-down cards need for
/// their own drag-and-drop reordering.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .headerView
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    var isDark: Bool = true
    var isWindowDraggable: Bool = false

    func makeNSView(context: Context) -> DraggableVisualEffectView {
        let view = DraggableVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        view.isWindowDraggable = isWindowDraggable
        return view
    }

    func updateNSView(_ nsView: DraggableVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        nsView.isWindowDraggable = isWindowDraggable
    }
}
