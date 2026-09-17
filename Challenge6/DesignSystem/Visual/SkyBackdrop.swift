import SwiftUI

struct SkyBackdrop: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppTheme.skyGradient

                Ellipse()
                    .fill(AppTheme.cloud.opacity(0.66))
                    .frame(width: geometry.size.width * 0.9, height: 150)
                    .blur(radius: 28)
                    .offset(x: -geometry.size.width * 0.22, y: -geometry.size.height * 0.31)

                Ellipse()
                    .fill(AppTheme.cloud.opacity(0.45))
                    .frame(width: geometry.size.width * 0.72, height: 120)
                    .blur(radius: 30)
                    .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.19)

                LinearGradient(
                    colors: [.clear, AppTheme.background.opacity(0.82), AppTheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .offset(y: geometry.size.height * 0.22)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview("Sky - Light") {
    SkyBackdrop()
        .preferredColorScheme(.light)
}

#Preview("Sky - Dark") {
    SkyBackdrop()
        .preferredColorScheme(.dark)
}
