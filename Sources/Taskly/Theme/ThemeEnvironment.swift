import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = DarkTheme()
}

extension EnvironmentValues {
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
