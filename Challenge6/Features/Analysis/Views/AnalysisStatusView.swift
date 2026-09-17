import SwiftUI

struct AnalysisStatusView: View {
    let state: AnalysisViewModel.State
    let retry: () -> Void

    init(
        state: AnalysisViewModel.State,
        retry: @escaping () -> Void = {}
    ) {
        self.state = state
        self.retry = retry
    }

    @ViewBuilder
    var body: some View {
        if case let .failure(failure) = state, failure != .emptyInput {
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Label {
                        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                            Text("We couldn’t check this")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(AppTheme.ink)
                            Text(failure.message)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppTheme.warning)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Unable to check. \(failure.message)")

                    Button("Retry", systemImage: "arrow.clockwise", action: retry)
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
            }
        }
    }
}

extension AnalysisViewModel.State {
    var accessibilityAnnouncement: String? {
        switch self {
        case .idle:
            nil
        case .loading:
            "Checking message on this device."
        case let .success(result):
            result.label == .suspicious
                ? "Analysis complete. Likely spam."
                : "Analysis complete. Likely not spam."
        case let .failure(failure):
            "Unable to check. \(failure.message)"
        }
    }
}

#Preview("Failure") {
    ZStack {
        SkyBackdrop()
        AnalysisStatusView(state: .failure(.serviceUnavailable))
            .padding()
    }
}
