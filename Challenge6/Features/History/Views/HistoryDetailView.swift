import SwiftUI

struct HistoryDetailView: View {
    let entry: AnalysisHistoryEntry

    private var title: String {
        entry.label == .suspicious ? "Likely Spam" : "Likely Not Spam"
    }

    private var icon: String {
        entry.label == .suspicious ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }

    private var tint: Color {
        entry.label == .suspicious ? .orange : .green
    }

    var body: some View {
        Form {
            Section("Result") {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(tint)
                LabeledContent("Confidence") {
                    Text(entry.confidence, format: .percent.precision(.fractionLength(0)))
                }
                LabeledContent("Analyzed") {
                    Text(entry.analyzedAt.formatted(date: .abbreviated, time: .shortened))
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Saved Message") {
                Text(entry.message)
                    .textSelection(.enabled)
                    .accessibilityLabel("Complete saved message. \(entry.message)")
            }

            Section("Model") {
                LabeledContent("Identifier", value: entry.modelIdentifier)
                LabeledContent("Version", value: entry.modelVersion)
            }

            Section("Remember") {
                Text("Confidence is a model score, not certainty. This learning-first demo is not professional safety advice. Independently verify suspicious or unexpected messages.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: AppSpacing.readableContentWidth)
        .frame(maxWidth: .infinity)
        .navigationTitle("Analysis Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
