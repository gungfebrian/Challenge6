import Foundation

enum CoreMLServiceContractTests {
    static func run() async {
        await mapsControlledPredictions()
        await mapsPredictionFailures()
        await preservesCancellation()
        rejectsMissingBundledModel()
    }

    private static func mapsControlledPredictions() async {
        let metadata = ModelMetadata(identifier: "test-model", version: "7", displayName: "Test Model")
        let service = CoreMLTextClassifierService(metadata: metadata) { _ in
            ["suspicious": 0.72, "legitimate": 0.28]
        }

        do {
            let result = try await service.analyze(AnalysisRequest(text: "test"))
            expect(result.label == .suspicious, "The service should map controlled NLModel hypotheses")
            expectApproximatelyEqual(result.confidence, 0.72, "The service should preserve mapped confidence")
            expect(result.model == metadata, "The service should propagate identifier and version")
        } catch {
            fatalError("Controlled valid predictions should succeed: \(error)")
        }
    }

    private static func mapsPredictionFailures() async {
        let failing = CoreMLTextClassifierService(metadata: .coreMLMaxEnt) { _ in
            throw FixtureFailure.unavailable
        }
        await expectServiceError(.predictionFailed, from: failing)

        let missing = CoreMLTextClassifierService(metadata: .coreMLMaxEnt) { _ in [:] }
        await expectServiceError(.predictionUnavailable, from: missing)

        let unsupported = CoreMLTextClassifierService(metadata: .coreMLMaxEnt) { _ in ["other": 1] }
        await expectServiceError(.unsupportedLabel("other"), from: unsupported)

        let invalid = CoreMLTextClassifierService(metadata: .coreMLMaxEnt) { _ in ["suspicious": .infinity] }
        await expectServiceError(.invalidPrediction, from: invalid)
    }

    private static func preservesCancellation() async {
        let service = CoreMLTextClassifierService(metadata: .coreMLMaxEnt) { _ in
            ["legitimate": 1]
        }
        let task = Task {
            try await service.analyze(AnalysisRequest(text: "cancelled"))
        }
        task.cancel()

        do {
            _ = try await task.value
            fatalError("A cancelled service task should not publish a prediction")
        } catch is CancellationError {
            // Expected: cancellation is deliberately preserved instead of becoming a model error.
        } catch {
            fatalError("Cancellation should remain CancellationError, received \(error)")
        }
    }

    private static func rejectsMissingBundledModel() {
        expectThrows("A missing model resource should return a typed load failure") {
            try CoreMLTextClassifierService(bundle: .main, resourceName: "MissingChallenge6Model")
        } validate: { $0 as? MLServiceError == .modelUnavailable }
    }

    private static func expectServiceError(
        _ expected: MLServiceError,
        from service: CoreMLTextClassifierService
    ) async {
        do {
            _ = try await service.analyze(AnalysisRequest(text: "test"))
            fatalError("Expected service error \(expected)")
        } catch let error as MLServiceError {
            expect(error == expected, "Expected \(expected), received \(error)")
        } catch {
            fatalError("Expected typed MLServiceError, received \(error)")
        }
    }
}

private enum FixtureFailure: Error {
    case unavailable
}
