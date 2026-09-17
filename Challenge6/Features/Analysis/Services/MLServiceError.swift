enum MLServiceError: Error, Equatable, Sendable {
    case modelUnavailable
    case predictionUnavailable
    case unsupportedLabel(String)
    case invalidPrediction
    case predictionFailed
}

struct UnavailableMLService: MLService {
    let error: MLServiceError

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try Task.checkCancellation()
        throw error
    }
}
