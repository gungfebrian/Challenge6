import SwiftUI

struct AnalysisStatusView: View {
    let state: AnalysisViewModel.State
    let persistenceWarning: AnalysisViewModel.PersistenceWarning?
    let retry: () -> Void
    let reset: () -> Void

    init(
        state: AnalysisViewModel.State,
        persistenceWarning: AnalysisViewModel.PersistenceWarning? = nil,
        retry: @escaping () -> Void = {},
        reset: @escaping () -> Void = {}
    ) {
        self.state = state
        self.persistenceWarning = persistenceWarning
        self.retry = retry
        self.reset = reset
    }

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            loadingContent
        case let .success(result):
            ResultContent(result: result, persistenceWarning: persistenceWarning, reset: reset)
        case let .failure(failure):
            FailureContent(failure: failure, retry: retry)
        }
    }

    private var loadingContent: some View {
        HStack(spacing: AppSpacing.medium) {
            ProgressView()
            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text("Analyzing message")
                    .font(.headline)
                Text("The Core ML model is running on this device.")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Analyzing message on this device. Please wait.")
    }
}

private struct FailureContent: View {
    let failure: AnalysisViewModel.Failure
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Label {
                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                    Text("Unable to Analyze")
                        .font(.headline)
                    Text(failure.message)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Unable to analyze. \(failure.message)")

            if failure != .emptyInput {
                Button("Retry", systemImage: "arrow.clockwise", action: retry)
                    .buttonStyle(.bordered)
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
            }
        }
    }
}

private struct ResultContent: View {
    let result: AnalysisResult
    let persistenceWarning: AnalysisViewModel.PersistenceWarning?
    let reset: () -> Void

    private var confidenceText: String {
        result.confidence.formatted(.percent.precision(.fractionLength(0)))
    }

    private var title: String {
        result.label == .suspicious ? "Likely Spam" : "Likely Not Spam"
    }

    private var systemImage: String {
        result.label == .suspicious ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }

    private var tint: Color {
        result.label == .suspicious ? .orange : .green
    }

    private var recommendation: String {
        switch result.label {
        case .suspicious:
            "Verify the sender another way, avoid links, and never share passwords or verification codes."
        case .legitimate:
            "Remain cautious and verify any unexpected request, especially one involving money or account access."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Label(title, systemImage: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .accessibilityLabel("\(title). Model confidence \(confidenceText). \(recommendation)")

            Gauge(value: result.confidence, in: 0...1) {
                Text("Model confidence")
            } currentValueLabel: {
                Text(confidenceText)
                    .font(.headline)
            }
            .tint(tint)
            .accessibilityLabel("Model confidence")
            .accessibilityValue(confidenceText)

            LabeledContent("Model") {
                Text("\(result.model.displayName) \(result.model.version)")
                    .multilineTextAlignment(.trailing)
            }
            .font(.subheadline)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text("Recommended next step")
                    .font(.headline)
                Text(recommendation)
                    .foregroundStyle(.secondary)
            }

            Text("Confidence is a model score, not certainty. This educational result is not professional safety advice.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let persistenceWarning {
                Label(persistenceWarning.message, systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .accessibilityLabel("History warning. \(persistenceWarning.message)")
            }

            Button("Check Another Message", systemImage: "arrow.counterclockwise", action: reset)
                .buttonStyle(.bordered)
                .frame(minHeight: AppSpacing.minimumTouchTarget)
        }
        .accessibilityElement(children: .contain)
    }
}

extension AnalysisViewModel.State {
    var accessibilityAnnouncement: String? {
        switch self {
        case .idle:
            nil
        case .loading:
            "Analyzing message on this device."
        case let .success(result):
            result.label == .suspicious
                ? "Analysis complete. Likely spam."
                : "Analysis complete. Likely not spam."
        case let .failure(failure):
            "Unable to analyze. \(failure.message)"
        }
    }
}

#Preview("Suspicious") {
    Form {
        AnalysisStatusView(
            state: .success(
                AnalysisResult(label: .suspicious, confidence: 0.82, model: .coreMLMaxEnt)
            )
        )
    }
}
