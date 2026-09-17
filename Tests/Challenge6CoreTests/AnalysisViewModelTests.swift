import Foundation

enum AnalysisViewModelTests {
    @MainActor
    static func run() async {
        await validatesAndPublishesResults()
        await savesOnlySuccessfulCurrentResults()
        await preservesResultsWhenPersistenceFails()
        await mapsTypedServiceFailures()
        await preventsDuplicateSubmissions()
    }

    @MainActor
    private static func validatesAndPublishesResults() async {
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

    @MainActor
    private static func savesOnlySuccessfulCurrentResults() async {
        let result = AnalysisResult(
            label: .suspicious,
            confidence: 0.88,
            model: ModelMetadata(identifier: "model-id", version: "2.0", displayName: "Model")
        )
        let date = Date(timeIntervalSince1970: 1_234)
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000123")!
        let enabledSaver = RecordingHistorySaver()
        let enabledViewModel = AnalysisViewModel(
            mlService: RecordingMLService(result: result),
            historySaver: enabledSaver,
            isHistorySavingEnabled: { true },
            now: { date },
            makeID: { id }
        )
        enabledViewModel.message = "  urgent message  "

        await enabledViewModel.analyze()

        expect(
            enabledSaver.entries == [
                AnalysisHistoryEntry(
                    id: id,
                    message: "urgent message",
                    label: .suspicious,
                    confidence: 0.88,
                    analyzedAt: date,
                    modelIdentifier: "model-id",
                    modelVersion: "2.0"
                )
            ],
            "A successful current result should save normalized text and model identity when enabled"
        )

        let disabledSaver = RecordingHistorySaver()
        let disabledViewModel = AnalysisViewModel(
            mlService: RecordingMLService(result: result),
            historySaver: disabledSaver,
            isHistorySavingEnabled: { false }
        )
        disabledViewModel.message = "message"
        await disabledViewModel.analyze()
        expect(disabledSaver.entries.isEmpty, "Disabling history should prevent future records")

        let unsuccessfulSaver = RecordingHistorySaver()
        let failedViewModel = AnalysisViewModel(mlService: FailingMLService(), historySaver: unsuccessfulSaver)
        failedViewModel.message = "message"
        await failedViewModel.analyze()

        let cancelledViewModel = AnalysisViewModel(mlService: CancellingMLService(), historySaver: unsuccessfulSaver)
        cancelledViewModel.message = "message"
        await cancelledViewModel.analyze()

        let controlled = ControlledMLService()
        let staleViewModel = AnalysisViewModel(mlService: controlled, historySaver: unsuccessfulSaver)
        staleViewModel.message = "old"
        let staleTask = Task { await staleViewModel.analyze() }
        await controlled.waitUntilRequested()
        staleViewModel.message = "new"
        await controlled.succeed(with: result)
        await staleTask.value

        expect(
            unsuccessfulSaver.entries.isEmpty,
            "Failed, cancelled, and stale analyses should never be persisted"
        )
    }

    @MainActor
    private static func preservesResultsWhenPersistenceFails() async {
        let result = AnalysisResult(label: .legitimate, confidence: 0.76, model: .coreMLMaxEnt)
        let viewModel = AnalysisViewModel(
            mlService: RecordingMLService(result: result),
            historySaver: FailingHistorySaver()
        )
        viewModel.message = "project update"

        await viewModel.analyze()

        expect(viewModel.state == .success(result), "A history failure should not erase a valid classifier result")
        expect(viewModel.persistenceWarning == .saveFailed, "A history failure should expose a separate renderable warning")
    }

    @MainActor
    private static func mapsTypedServiceFailures() async {
        let unavailable = AnalysisViewModel(mlService: UnavailableMLService(error: .modelUnavailable))
        unavailable.message = "message"
        await unavailable.analyze()
        expect(unavailable.state == .failure(.modelUnavailable), "Model load errors should produce a recoverable unavailable state")

        let invalid = AnalysisViewModel(mlService: UnavailableMLService(error: .predictionUnavailable))
        invalid.message = "message"
        await invalid.analyze()
        expect(invalid.state == .failure(.predictionUnavailable), "Missing predictions should have distinct recovery copy")
    }

    @MainActor
    private static func preventsDuplicateSubmissions() async {
        let service = ControlledMLService()
        let viewModel = AnalysisViewModel(mlService: service)
        viewModel.message = "one message"
        let first = Task { await viewModel.analyze() }
        await service.waitUntilRequested()

        await viewModel.analyze()

        let requestCount = await service.requestCount
        expect(requestCount == 1, "A loading view model should ignore duplicate submissions")
        await service.succeed(with: AnalysisResult(label: .legitimate, confidence: 0.7))
        await first.value
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
    private(set) var requestCount = 0

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        requestCount += 1
        return try await withCheckedThrowingContinuation { continuation in
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

@MainActor
private final class RecordingHistorySaver: AnalysisHistorySaving {
    private(set) var entries: [AnalysisHistoryEntry] = []

    func save(_ entry: AnalysisHistoryEntry) throws {
        entries.append(entry)
    }
}

@MainActor
private final class FailingHistorySaver: AnalysisHistorySaving {
    func save(_ entry: AnalysisHistoryEntry) throws {
        throw FixtureHistoryError.couldNotSave
    }
}

private enum FixtureHistoryError: Error {
    case couldNotSave
}
