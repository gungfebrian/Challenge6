import SwiftUI

struct CheckHelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let facts: [HelpFact] = [
        HelpFact(
            id: "dataset",
            systemImage: "books.vertical.fill",
            title: "A known learning dataset",
            body: "The model was trained on 5,574 labeled English SMS messages from the UCI SMS Spam Collection."
        ),
        HelpFact(
            id: "examples",
            systemImage: "sparkles",
            title: "Fresh walkthrough examples",
            body: "The three demo examples are new walkthrough messages, not training records."
        ),
        HelpFact(
            id: "privacy",
            systemImage: "lock.shield.fill",
            title: "Private by design",
            body: "Analysis runs locally on your device and messages are not uploaded."
        ),
        HelpFact(
            id: "limits",
            systemImage: "scope",
            title: "A score, not certainty",
            body: "The dataset is older and English-focused; confidence is a score, not certainty."
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    GuardianMascotView(mood: .idle, size: 132)
                        .accessibilityHidden(true)

                    VStack(spacing: AppSpacing.extraSmall) {
                        Text("How Spam Check works")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(AppTheme.ink)
                        Text("A small, on-device learning model helps you pause before trusting a message.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    AppCard {
                        VStack(spacing: 0) {
                            ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                                HelpFactRow(fact: fact)

                                if index < facts.count - 1 {
                                    Divider()
                                        .padding(.leading, 52)
                                }
                            }
                        }
                    }

                    NavigationLink {
                        ModelInformationView()
                    } label: {
                        HStack {
                            Label("Model & Dataset Details", systemImage: "info.circle.fill")
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(AppTheme.primary)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                        .padding(.horizontal, AppSpacing.medium)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.fieldRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.fieldRadius)
                                .stroke(AppTheme.outline, lineWidth: 1)
                        }
                    }
                    .accessibilityHint("Shows model version, dataset attribution, privacy, and limitations.")
                }
                .frame(maxWidth: AppTheme.compactContentWidth)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.medium)
                .padding(.bottom, AppSpacing.large)
            }
            .background(AppTheme.background)
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .tint(AppTheme.primary)
        .presentationBackground(AppTheme.background)
    }
}

private struct HelpFact: Identifiable {
    let id: String
    let systemImage: String
    let title: String
    let body: String
}

private struct HelpFactRow: View {
    let fact: HelpFact

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Image(systemName: fact.systemImage)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 40, height: 40)
                .background(AppTheme.cloud, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(fact.title)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(fact.body)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CheckHelpSheet()
}
