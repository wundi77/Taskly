import SwiftUI

struct LabelChipView: View {
    var label: CardLabel
    @Environment(\.theme) private var theme

    var body: some View {
        Text(label.name.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.4)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(theme.labelBackground(for: label.colorName))
            .foregroundStyle(theme.labelForeground(for: label.colorName))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
