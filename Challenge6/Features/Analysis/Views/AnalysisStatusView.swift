//
//  AnalysisStatusView.swift
//  Challenge6
//

import SwiftUI

struct AnalysisStatusView: View {
    let state: AnalysisViewModel.State

    var body: some View {
        switch state {
        case .idle:
            Label("Enter a message to begin.", systemImage: "text.bubble")
                .foregroundStyle(.secondary)

        case .loading:
            HStack(spacing: AppSpacing.medium) {
                ProgressView()

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Analyzing message")
                        .font(.headline)
                    Text("The Naive Bayes service is checking the text.")
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Analyzing message. Please wait.")

        case let .success(result):
            ResultContent(result: result)

        case let .failure(message):
            Label {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Unable to analyze")
                        .font(.headline)
                    Text(message)
                }
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Unable to analyze. \(message)")
        }
    }
}

private struct ResultContent: View {
    let result: AnalysisResult

    private var confidenceText: String {
        result.confidence.formatted(.percent.precision(.fractionLength(0)))
    }

    private var title: String {
        switch result.label {
        case .suspicious:
            "Likely spam"
        case .legitimate:
            "Likely not spam"
        }
    }

    private var systemImage: String {
        switch result.label {
        case .suspicious:
            "exclamationmark.shield.fill"
        case .legitimate:
            "checkmark.shield.fill"
        }
    }

    private var tint: Color {
        switch result.label {
        case .suspicious:
            .orange
        case .legitimate:
            .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(tint)

            Gauge(value: result.confidence) {
                Text("Demo confidence")
            } currentValueLabel: {
                Text(confidenceText)
            }
            .tint(tint)

            Text("This result comes from simple demo keywords, not a trained model. Do not use it as safety advice.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). Demo confidence \(confidenceText). This is not safety advice.")
    }
}

extension AnalysisViewModel.State {
    var accessibilityAnnouncement: String? {
        switch self {
        case .idle:
            nil
        case .loading:
            "Analyzing message."
        case let .success(result):
            result.label == .suspicious
                ? "Analysis complete. Likely spam."
                : "Analysis complete. Likely not spam."
        case let .failure(message):
            "Unable to analyze. \(message)"
        }
    }
}

#Preview("Suspicious") {
    Form {
        AnalysisStatusView(
            state: .success(AnalysisResult(label: .suspicious, confidence: 0.82))
        )
    }
}
