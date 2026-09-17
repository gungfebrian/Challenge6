import Accessibility
import SwiftUI

struct AnalysisView: View {
    @State private var viewModel: AnalysisViewModel
    @State private var analysisTask: Task<Void, Never>?
    @State private var successFeedbackTrigger = 0
    @State private var warningFeedbackTrigger = 0
    @State private var errorFeedbackTrigger = 0
    @FocusState private var isEditorFocused: Bool
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback = true

    init(
        mlService: any MLService,
        historySaver: (any AnalysisHistorySaving)? = nil,
        isHistorySavingEnabled: @escaping () -> Bool = { true }
    ) {
        _viewModel = State(
            initialValue: AnalysisViewModel(
                mlService: mlService,
                historySaver: historySaver,
                isHistorySavingEnabled: isHistorySavingEnabled
            )
        )
    }

    var body: some View {
        Form {
            introSection
            examplesSection
            editorSection
            analyzeSection
            statusSection
        }
        .formStyle(.grouped)
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: AppSpacing.readableContentWidth)
        .frame(maxWidth: .infinity)
        .navigationTitle("Spam Check")
        .sensoryFeedback(.success, trigger: successFeedbackTrigger)
        .sensoryFeedback(.warning, trigger: warningFeedbackTrigger)
        .sensoryFeedback(.error, trigger: errorFeedbackTrigger)
        .onChange(of: viewModel.state, handleStateChange)
        .onDisappear {
            analysisTask?.cancel()
        }
    }

    private var introSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Label("Private, on-device analysis", systemImage: "iphone.and.arrow.forward.inward")
                    .font(.headline)

                Text("Check an English message with a learning-first Core ML model. Your message is not sent to a server.")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, AppSpacing.extraSmall)
            .accessibilityElement(children: .combine)
        }
    }

    private var examplesSection: some View {
        Section {
            ForEach(DemoExample.all) { example in
                Button {
                    viewModel.message = example.message
                    isEditorFocused = true
                } label: {
                    HStack(spacing: AppSpacing.medium) {
                        Image(systemName: example.systemImage)
                            .frame(width: AppSpacing.large)

                        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                            Text(example.kind.rawValue)
                                .font(.headline)
                            Text(example.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                        Image(systemName: "arrow.down.to.line.compact")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(.rect)
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Use \(example.kind.rawValue.lowercased()) example")
                .accessibilityHint("Fills the message editor without starting analysis.")
            }
        } header: {
            Text("Quick Examples")
        } footer: {
            Text("The ambiguous example helps show why a model score is not certainty.")
        }
    }

    private var editorSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                if viewModel.message.isEmpty {
                    Text("Paste or type an English SMS message")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, AppSpacing.extraSmall)
                        .padding(.vertical, AppSpacing.small)
                        .accessibilityHidden(true)
                }

                TextEditor(text: $viewModel.message)
                    .focused($isEditorFocused)
                    .frame(minHeight: 144)
                    .scrollContentBackground(.hidden)
                    .accessibilityLabel("Message to analyze")
                    .accessibilityHint("Enter or paste the message you want to check.")
                    .disabled(viewModel.isAnalyzing)
            }

            if case .failure(.emptyInput) = viewModel.state {
                Label("Enter a message before analyzing.", systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error. Enter a message before analyzing.")
            }
        } header: {
            HStack {
                Text("Message")
                Spacer()
                Button("Clear", systemImage: "xmark.circle") {
                    cancelAndReset()
                    isEditorFocused = true
                }
                .disabled(viewModel.message.isEmpty && !viewModel.isAnalyzing)
                .frame(minHeight: AppSpacing.minimumTouchTarget)
                .accessibilityHint("Clears the message and current result.")
            }
        } footer: {
            Text("Confidence is a model score, not certainty. Independently verify suspicious or unexpected messages.")
        }
    }

    private var analyzeSection: some View {
        Section {
            Button(action: startAnalysis) {
                HStack {
                    Spacer()
                    if viewModel.isAnalyzing {
                        ProgressView()
                            .controlSize(.small)
                        Text("Analyzing…")
                    } else {
                        Label("Analyze Message", systemImage: "checkmark.shield")
                    }
                    Spacer()
                }
                .frame(minHeight: AppSpacing.minimumTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isAnalyzing)
            .accessibilityHint("Analyzes the message with the on-device Core ML model.")
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var statusSection: some View {
        if viewModel.state != .idle {
            Section("Analysis Result") {
                AnalysisStatusView(
                    state: viewModel.state,
                    persistenceWarning: viewModel.persistenceWarning,
                    retry: startAnalysis,
                    reset: {
                        cancelAndReset()
                        isEditorFocused = true
                    }
                )
            }
        }
    }

    private func startAnalysis() {
        guard !viewModel.isAnalyzing else { return }
        isEditorFocused = false
        analysisTask = Task {
            await viewModel.analyze()
        }
    }

    private func cancelAndReset() {
        analysisTask?.cancel()
        analysisTask = nil
        viewModel.reset()
    }

    private func handleStateChange(
        oldValue: AnalysisViewModel.State,
        newValue: AnalysisViewModel.State
    ) {
        guard oldValue != newValue else { return }

        if let announcement = newValue.accessibilityAnnouncement {
            AccessibilityNotification.Announcement(announcement).post()
        }

        switch newValue {
        case .success(let result) where hapticFeedback:
            if result.label == .suspicious {
                warningFeedbackTrigger += 1
            } else {
                successFeedbackTrigger += 1
            }
        case .failure(.emptyInput):
            isEditorFocused = true
            if hapticFeedback { errorFeedbackTrigger += 1 }
        case .failure:
            if hapticFeedback { errorFeedbackTrigger += 1 }
        case .idle, .loading, .success:
            break
        }
    }
}

#Preview {
    NavigationStack {
        AnalysisView(mlService: MultinomialNaiveBayesService())
    }
}
