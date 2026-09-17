import SwiftUI

struct AnalysisResultSheet: View {
    let result: AnalysisResult
    let persistenceWarning: AnalysisViewModel.PersistenceWarning?
    let onCheckAnother: () -> Void

    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var isVerdictFocused: Bool

    private var isSuspicious: Bool { result.label == .suspicious }

    private var verdict: String {
        isSuspicious ? "Likely Spam" : "Likely Not Spam"
    }

    private var confidenceText: String {
        result.confidence.formatted(.percent.precision(.fractionLength(0)))
    }

    private var mood: GuardianMood {
        isSuspicious ? .warning : .safe
    }

    private var tint: Color {
        isSuspicious ? AppTheme.warning : AppTheme.safe
    }

    private var tintSurface: Color {
        isSuspicious ? AppTheme.warningSurface : AppTheme.safeSurface
    }

    private var recommendationTitle: String {
        isSuspicious ? "Pause before you act" : "Still stay alert"
    }

    private var recommendationBody: String {
        if isSuspicious {
            "Don’t tap links or share codes. Verify the sender another way."
        } else {
            "Verify unexpected requests, especially about money or account access."
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    VStack(spacing: AppSpacing.small) {
                        GuardianMascotView(mood: mood, size: 168)
                            .accessibilityHidden(true)

                        Text(verdict)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(tint)
                            .accessibilityFocused($isVerdictFocused)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(verdict)

                    VStack(spacing: AppSpacing.small) {
                        Text(confidenceText)
                            .font(.system(size: 58, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(AppTheme.ink)
                        Text("Model confidence")
                            .font(.headline)
                            .foregroundStyle(AppTheme.secondaryText)

                        ProgressView(value: result.confidence, total: 1)
                            .tint(tint)
                            .accessibilityLabel("Model confidence")
                            .accessibilityValue(confidenceText)
                    }
                    .accessibilityElement(children: .combine)

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Label(recommendationTitle, systemImage: isSuspicious ? "hand.raised.fill" : "eye.fill")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(tint)
                        Text(recommendationBody)
                            .foregroundStyle(AppTheme.ink)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.large)
                    .background(tintSurface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                    .accessibilityElement(children: .combine)

                    AppCard {
                        DisclosureGroup("Learn more") {
                            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                                LabeledContent("Model") {
                                    Text("\(result.model.displayName) \(result.model.version)")
                                        .multilineTextAlignment(.trailing)
                                }

                                Text("Confidence is a model score, not certainty. This educational result is not professional safety advice.")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            .padding(.top, AppSpacing.small)
                        }
                        .font(.headline)
                        .tint(AppTheme.primary)
                    }

                    if let persistenceWarning {
                        Label(persistenceWarning.message, systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppTheme.warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("History warning. \(persistenceWarning.message)")
                    }

                    Button("Check Another Message", systemImage: "arrow.counterclockwise", action: finish)
                        .buttonStyle(PrimaryActionButtonStyle())
                }
                .frame(maxWidth: AppTheme.compactContentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.extraLarge)
            }
            .background(AppTheme.background)
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close", action: finish)
                }
            }
        }
        .tint(AppTheme.primary)
        .presentationBackground(AppTheme.background)
        .onAppear {
            isVerdictFocused = true
        }
    }

    private func finish() {
        onCheckAnother()
        dismiss()
    }
}

#Preview("Suspicious") {
    AnalysisResultSheet(
        result: AnalysisResult(label: .suspicious, confidence: 0.91, model: .coreMLMaxEnt),
        persistenceWarning: nil,
        onCheckAnother: {}
    )
}

#Preview("Legitimate Dark") {
    AnalysisResultSheet(
        result: AnalysisResult(label: .legitimate, confidence: 0.84, model: .coreMLMaxEnt),
        persistenceWarning: .saveFailed,
        onCheckAnother: {}
    )
    .preferredColorScheme(.dark)
}
