import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded, weight: .bold))
            .dynamicTypeSize(.xSmall ... .accessibility1)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, minHeight: AppTheme.primaryControlHeight)
            .foregroundStyle(isEnabled ? AppTheme.primaryActionForeground : AppTheme.secondaryText)
            .background {
                Capsule()
                    .fill(isEnabled ? AppTheme.primaryGradient : LinearGradient(colors: [AppTheme.outline], startPoint: .leading, endPoint: .trailing))
            }
            .opacity(configuration.isPressed ? 0.84 : isEnabled ? 1 : 0.68)
            .shadow(
                color: isEnabled && !configuration.isPressed ? AppTheme.primary.opacity(0.24) : .clear,
                radius: 12,
                y: 7
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: AppSpacing.medium) {
        Button("Check Message") {}
            .buttonStyle(PrimaryActionButtonStyle())

        Button("Checking…") {}
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(true)
    }
    .padding()
}
