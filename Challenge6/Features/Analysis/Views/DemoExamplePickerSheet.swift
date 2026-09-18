import SwiftUI

struct DemoExamplePickerSheet: View {
    let onSelect: (DemoExample) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer(minLength: 0)
                        Image("GuardianTryDemo")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 112, height: 112)
                            .accessibilityHidden(true)
                        Spacer(minLength: 0)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(DemoExample.all) { example in
                        Button {
                            onSelect(example)
                        } label: {
                            HStack(spacing: AppSpacing.medium) {
                                Image(systemName: example.systemImage)
                                    .font(.title3)
                                    .foregroundStyle(symbolColor(for: example.kind))
                                    .frame(width: AppSpacing.minimumTouchTarget, height: AppSpacing.minimumTouchTarget)
                                    .background(symbolSurface(for: example.kind), in: Circle())

                                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                                    Text(example.kind.rawValue)
                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                        .foregroundStyle(AppTheme.ink)
                                    Text(example.message)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.secondaryText)
                                        .lineLimit(3)
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "arrow.down.to.line.compact")
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .accessibilityHidden(true)
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Use \(example.kind.rawValue.lowercased()) example")
                        .accessibilityHint("Fills the message editor without starting analysis.")
                        .listRowBackground(AppTheme.surface)
                    }
                } footer: {
                    Text("These handcrafted messages demonstrate possible outcomes. They are not records from the model’s training dataset.")
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Try an example")
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

    private func symbolColor(for kind: DemoExample.Kind) -> Color {
        switch kind {
        case .suspicious: AppTheme.warning
        case .legitimate: AppTheme.safe
        case .ambiguous: AppTheme.primary
        }
    }

    private func symbolSurface(for kind: DemoExample.Kind) -> Color {
        switch kind {
        case .suspicious: AppTheme.warningSurface
        case .legitimate: AppTheme.safeSurface
        case .ambiguous: AppTheme.cloud
        }
    }
}

#Preview {
    DemoExamplePickerSheet { _ in }
}
