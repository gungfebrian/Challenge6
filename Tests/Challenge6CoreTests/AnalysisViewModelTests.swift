enum AnalysisViewModelTests {
    @MainActor
    static func run() async {
        let viewModel = AnalysisViewModel(mlService: UnexpectedCallService())
        viewModel.message = "   \n"

        await viewModel.analyze()

        expect(
            viewModel.state == .failure(.emptyInput),
            "Blank input should produce a typed empty-input failure"
        )

        let expectedResult = AnalysisResult(label: .suspicious, confidence: 0.82)
        let recordingService = RecordingMLService(result: expectedResult)
        let successfulViewModel = AnalysisViewModel(mlService: recordingService)
        successfulViewModel.message = "  urgent click  "

        await successfulViewModel.analyze()

        expect(
            successfulViewModel.state == .success(expectedResult),
            "Successful analysis should publish its result"
        )
        let receivedText = await recordingService.receivedText
        expect(
            receivedText == "urgent click",
            "The ViewModel should send normalized input to the service"
        )

        let failingViewModel = AnalysisViewModel(mlService: FailingMLService())
        failingViewModel.message = "hello"

        await failingViewModel.analyze()

        expect(
            failingViewModel.state == .failure(.serviceUnavailable),
            "Service errors should become renderable failures"
        )

        let cancellingViewModel = AnalysisViewModel(mlService: CancellingMLService())
        cancellingViewModel.message = "hello"

        await cancellingViewModel.analyze()

        expect(
            cancellingViewModel.state == .idle,
            "Cancellation should restore the idle state"
        )

        let controlledService = ControlledMLService()
        let staleViewModel = AnalysisViewModel(mlService: controlledService)
        staleViewModel.message = "first message"
        let analysisTask = Task {
            await staleViewModel.analyze()
        }

        await controlledService.waitUntilRequested()
        staleViewModel.message = "second message"
        await controlledService.succeed(
            with: AnalysisResult(label: .suspicious, confidence: 0.9)
        )
        await analysisTask.value

        expect(
            staleViewModel.state == .idle,
            "A result for older input should not replace state for newer input"
        )
    }
}

private actor RecordingMLService: MLService {
    private(set) var receivedText: String?
    private let result: AnalysisResult

    init(result: AnalysisResult) {
        self.result = result
    }

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        receivedText = request.text
        return result
    }
}

private struct UnexpectedCallService: MLService {
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        fatalError("The ML service should not receive blank input")
    }
}

private struct FailingMLService: MLService {
    enum Failure: Error {
        case unavailable
    }

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        throw Failure.unavailable
    }
}

private struct CancellingMLService: MLService {
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        throw CancellationError()
    }
}

private actor ControlledMLService: MLService {
    private var continuation: CheckedContinuation<AnalysisResult, Error>?

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func waitUntilRequested() async {
        while continuation == nil {
            await Task.yield()
        }
    }

    func succeed(with result: AnalysisResult) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
