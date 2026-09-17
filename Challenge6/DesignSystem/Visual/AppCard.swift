import SwiftUI

struct AppCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface)
            .clipShape(.rect(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .stroke(AppTheme.outline.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: AppTheme.shadow, radius: 18, y: 10)
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        AppCard {
            Text("One calm card")
                .foregroundStyle(AppTheme.ink)
        }
        .padding()
    }
}
