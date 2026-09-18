import SwiftUI

enum GuardianMood: String {
    case idle
    case checking
    case safe
    case warning

    var assetName: String {
        switch self {
        case .idle: "GuardianIdle"
        case .checking: "GuardianChecking"
        case .safe: "GuardianSafe"
        case .warning: "GuardianWarning"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .idle: "Message shield guardian"
        case .checking: "Message shield guardian checking the message"
        case .safe: "Message shield guardian showing a reassuring result"
        case .warning: "Message shield guardian showing a warning result"
        }
    }
}

struct GuardianMascotView: View {
    let mood: GuardianMood
    let size: CGFloat
    let allowsIdleMotion: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationPhase = false

    init(
        mood: GuardianMood,
        size: CGFloat,
        allowsIdleMotion: Bool = false
    ) {
        self.mood = mood
        self.size = size
        self.allowsIdleMotion = allowsIdleMotion
    }

    var body: some View {
        ZStack {
            if mood == .checking {
                Image("GuardianMotionHalo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 1.14, height: size * 1.14)
                    .rotationEffect(haloRotation)
                    .opacity(haloOpacity)
                    .accessibilityHidden(true)
            }

            Image(mood.assetName)
                .interpolation(.high)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        .offset(y: idleOffset)
        .scaleEffect(checkingScale)
        .animation(activeAnimation, value: animationPhase)
        .accessibilityLabel(mood.accessibilityLabel)
        .onAppear(perform: updateAnimation)
        .onChange(of: reduceMotion) { _, _ in
            updateAnimation()
        }
        .onChange(of: mood) { _, _ in
            animationPhase = false
            updateAnimation()
        }
    }

    private var idleOffset: CGFloat {
        guard mood == .idle, animationPhase else { return 0 }
        return -2
    }

    private var checkingScale: CGFloat {
        guard !reduceMotion, mood == .checking, animationPhase else { return 1 }
        return 1.04
    }

    private var haloRotation: Angle {
        guard !reduceMotion else { return .zero }
        return .degrees(animationPhase ? 10 : -10)
    }

    private var haloOpacity: Double {
        guard !reduceMotion else { return 0.58 }
        return animationPhase ? 0.92 : 0.5
    }

    private var activeAnimation: Animation? {
        guard GuardianMotionPolicy.shouldAnimate(
            mood.animationState,
            reduceMotion: reduceMotion,
            allowsIdleMotion: allowsIdleMotion
        ) else { return nil }
        return .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
    }

    private func updateAnimation() {
        animationPhase = GuardianMotionPolicy.shouldAnimate(
            mood.animationState,
            reduceMotion: reduceMotion,
            allowsIdleMotion: allowsIdleMotion
        )
    }
}

private extension GuardianMood {
    var animationState: GuardianAnimationState {
        switch self {
        case .idle: .idle
        case .checking: .checking
        case .safe: .safe
        case .warning: .warning
        }
    }
}

#Preview("Guardian moods") {
    HStack {
        ForEach([GuardianMood.idle, .checking, .safe, .warning], id: \.rawValue) { mood in
            GuardianMascotView(mood: mood, size: 120)
        }
    }
    .padding()
    .background(AppTheme.background)
}

#Preview("Guardian - Dark large text") {
    GuardianMascotView(mood: .idle, size: 180)
        .padding()
        .background(AppTheme.background)
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}
