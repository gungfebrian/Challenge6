import Accessibility
import SwiftUI

struct AnalysisView: View {
    @State private var viewModel: AnalysisViewModel
    @State private var analysisTask: Task<Void, Never>?
    @State private var didStartPreviewAnalysis = false
    @State private var activeSheet: ActiveCheckSheet?
    @State private var shouldFocusEditorAfterSheet = false
    @State private var successFeedbackTrigger = 0
    @State private var warningFeedbackTrigger = 0
    @State private var errorFeedbackTrigger = 0
    @FocusState private var isEditorFocused: Bool
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback = true
    private let startsAnalysisOnAppear: Bool

    init(
        mlService: any MLService,
        historySaver: (any AnalysisHistorySaving)? = nil,
        isHistorySavingEnabled: @escaping () -> Bool = { true },
        initialMessage: String = "",
        startsAnalysisOnAppear: Bool = false
    ) {
        let model = AnalysisViewModel(
            mlService: mlService,
            historySaver: historySaver,
            isHistorySavingEnabled: isHistorySavingEnabled
        )
        model.message = initialMessage
        _viewModel = State(initialValue: model)
        self.startsAnalysisOnAppear = startsAnalysisOnAppear
    }

    var body: some View {
        ZStack {
            SkyBackdrop()

            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    identitySection
                    messageCard
                    AnalysisStatusView(state: viewModel.state, retry: startAnalysis)
                }
                .frame(maxWidth: AppTheme.compactContentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.extraLarge)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            checkButton
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.extraSmall)
                .background(
                    LinearGradient(
                        colors: [AppTheme.background.opacity(0), AppTheme.background],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isEditorFocused = false }
            }
        }
        .sheet(item: $activeSheet, onDismiss: handleSheetDismissal) { sheet in
            sheetContent(for: sheet)
        }
        .sensoryFeedback(.success, trigger: successFeedbackTrigger)
        .sensoryFeedback(.warning, trigger: warningFeedbackTrigger)
        .sensoryFeedback(.error, trigger: errorFeedbackTrigger)
        .onChange(of: viewModel.state, handleStateChange)
        .onChange(of: viewModel.persistenceWarning) { _, warning in
            guard let warning else { return }
            AccessibilityNotification.Announcement("History warning. \(warning.message)").post()
        }
        .onDisappear {
            analysisTask?.cancel()
        }
        .task {
            guard startsAnalysisOnAppear, !didStartPreviewAnalysis else { return }
            didStartPreviewAnalysis = true
            startAnalysis()
        }
    }

    private var identitySection: some View {
        VStack(spacing: AppSpacing.small) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                    Text("Spam Check")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.ink)

                    Text("Check a message before you trust it.")
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer(minLength: AppSpacing.small)

                Button {
                    isEditorFocused = false
                    activeSheet = .help
                } label: {
                    Image(systemName: "questionmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                        .frame(width: AppSpacing.minimumTouchTarget, height: AppSpacing.minimumTouchTarget)
                        .background(AppTheme.surface.opacity(0.92), in: Circle())
                        .overlay(Circle().stroke(AppTheme.outline, lineWidth: 1))
                }
                .accessibilityLabel("How Spam Check works")
                .accessibilityHint("Opens privacy, dataset, and model information.")
            }

            GuardianMascotView(mood: viewModel.isAnalyzing ? .checking : .idle, size: 176)
                .accessibilityHidden(true)

            Label("Private • On-device", systemImage: "lock.shield.fill")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.safe)
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: AppSpacing.minimumTouchTarget)
                .background(AppTheme.safeSurface, in: Capsule())
                .accessibilityLabel("Private. Analysis runs on this device.")
        }
        .accessibilityElement(children: .contain)
    }

    private var messageCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack {
                    Text("Message")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.ink)

                    Spacer()

                    Button {
                        cancelAndReset()
                        isEditorFocused = true
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(minHeight: AppSpacing.minimumTouchTarget)
                    }
                    .disabled(viewModel.message.isEmpty && !viewModel.isAnalyzing)
                    .accessibilityHint("Clears the message and current result.")
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.message.isEmpty {
                        Text("Paste or type an English SMS message")
                            .foregroundStyle(AppTheme.secondaryText.opacity(0.75))
                            .padding(.horizontal, AppSpacing.medium)
                            .padding(.vertical, AppSpacing.small)
                            .accessibilityHidden(true)
                    }

                    TextEditor(text: $viewModel.message)
                        .focused($isEditorFocused)
                        .frame(minHeight: 132)
                        .padding(.horizontal, AppSpacing.small)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityLabel("Message")
                        .accessibilityHint("Enter or paste the message you want to check.")
                        .disabled(viewModel.isAnalyzing)
                }
                .background(AppTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: AppTheme.fieldRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.fieldRadius)
                        .stroke(
                            isEditorFocused ? AppTheme.primary : AppTheme.outline,
                            lineWidth: isEditorFocused ? 2 : 1
                        )
                }

                if case .failure(.emptyInput) = viewModel.state {
                    Label("Enter a message before checking.", systemImage: "exclamationmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.warning)
                        .accessibilityLabel("Error. Enter a message before checking.")
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: AppSpacing.small) {
                        inputHint
                        Spacer(minLength: AppSpacing.small)
                        exampleButton
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        inputHint
                        exampleButton
                    }
                }
            }
        }
    }

    private var inputHint: some View {
        Label("English messages work best", systemImage: "text.bubble")
            .font(.footnote)
            .foregroundStyle(AppTheme.secondaryText)
            .accessibilityElement(children: .combine)
    }

    private var exampleButton: some View {
        Button {
            isEditorFocused = false
            activeSheet = .examples
        } label: {
            Label("Try an example", systemImage: "sparkles")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .frame(minHeight: AppSpacing.minimumTouchTarget)
        }
        .buttonStyle(.bordered)
        .tint(AppTheme.primary)
        .disabled(viewModel.isAnalyzing)
        .accessibilityHint("Opens three walkthrough messages. Selecting one does not start analysis.")
    }

    private var checkButton: some View {
        Button(action: startAnalysis) {
            HStack(spacing: AppSpacing.small) {
                if viewModel.isAnalyzing {
                    ProgressView()
                        .tint(.white)
                    Text("Checking…")
                } else {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Check Message")
                }
            }
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .disabled(viewModel.isAnalyzing)
        .accessibilityHint("Checks the message with the on-device model.")
    }

    @ViewBuilder
    private func sheetContent(for sheet: ActiveCheckSheet) -> some View {
        switch sheet {
        case .help:
            CheckHelpSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        case .examples:
            DemoExamplePickerSheet { example in
                viewModel.message = example.message
                shouldFocusEditorAfterSheet = true
                activeSheet = nil
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        case let .result(result):
            AnalysisResultSheet(
                result: result,
                persistenceWarning: viewModel.persistenceWarning,
                onCheckAnother: {
                    activeSheet = nil
                }
            )
            .interactiveDismissDisabled(false)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
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

    private func handleSheetDismissal() {
        if case .success = viewModel.state {
            cancelAndReset()
            return
        }

        if shouldFocusEditorAfterSheet {
            shouldFocusEditorAfterSheet = false
            isEditorFocused = true
        }
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
        case let .success(result):
            activeSheet = .result(result)
            if hapticFeedback {
                if result.label == .suspicious {
                    warningFeedbackTrigger += 1
                } else {
                    successFeedbackTrigger += 1
                }
            }
        case .failure(.emptyInput):
            isEditorFocused = true
            if hapticFeedback { errorFeedbackTrigger += 1 }
        case .failure:
            if hapticFeedback { errorFeedbackTrigger += 1 }
        case .idle, .loading:
            break
        }
    }
}

private enum ActiveCheckSheet: Identifiable {
    case help
    case examples
    case result(AnalysisResult)

    var id: String {
        switch self {
        case .help: "help"
        case .examples: "examples"
        case .result: "result"
        }
    }
}

#Preview("Idle") {
    NavigationStack {
        AnalysisView(mlService: MultinomialNaiveBayesService())
    }
}

#Preview("Dark") {
    NavigationStack {
        AnalysisView(mlService: MultinomialNaiveBayesService())
    }
    .preferredColorScheme(.dark)
}

#Preview("Filled Editor") {
    NavigationStack {
        AnalysisView(
            mlService: PreviewMLService(outcome: .legitimate),
            initialMessage: DemoExample.all[1].message
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AnalysisView(
            mlService: PreviewMLService(outcome: .loading),
            initialMessage: DemoExample.all[0].message,
            startsAnalysisOnAppear: true
        )
    }
}

#Preview("Empty Validation") {
    NavigationStack {
        AnalysisView(
            mlService: PreviewMLService(outcome: .legitimate),
            startsAnalysisOnAppear: true
        )
    }
}

#Preview("Service Failure") {
    NavigationStack {
        AnalysisView(
            mlService: PreviewMLService(outcome: .failure),
            initialMessage: DemoExample.all[2].message,
            startsAnalysisOnAppear: true
        )
    }
}

#Preview("Accessibility Text") {
    NavigationStack {
        AnalysisView(mlService: MultinomialNaiveBayesService())
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

private struct PreviewMLService: MLService {
    enum Outcome: Sendable {
        case legitimate
        case loading
        case failure
    }

    let outcome: Outcome

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        switch outcome {
        case .legitimate:
            return AnalysisResult(label: .legitimate, confidence: 0.84, model: .coreMLMaxEnt)
        case .loading:
            try await Task.sleep(for: .seconds(3_600))
            return AnalysisResult(label: .legitimate, confidence: 0.84, model: .coreMLMaxEnt)
        case .failure:
            throw MLServiceError.predictionFailed
        }
    }
}
