import CoreML
import Foundation
import NaturalLanguage

/// Owns the non-Sendable Natural Language runtime behind actor isolation.
actor CoreMLTextClassifierService: MLService {
    typealias PredictionProvider = @Sendable (String) throws -> [String: Double]

    private let model: NLModel?
    private let predictionProvider: PredictionProvider?
    private let metadata: ModelMetadata

    init(
        bundle: Bundle = .main,
        resourceName: String = "SpamClassifierMaxEntV1",
        metadata: ModelMetadata = .coreMLMaxEnt
    ) throws {
        guard let modelURL = bundle.url(forResource: resourceName, withExtension: "mlmodelc") else {
            throw MLServiceError.modelUnavailable
        }

        do {
            let configuration = MLModelConfiguration()
            let coreMLModel = try MLModel(contentsOf: modelURL, configuration: configuration)
            model = try NLModel(mlModel: coreMLModel)
            predictionProvider = nil
            self.metadata = metadata
        } catch {
            throw MLServiceError.modelUnavailable
        }
    }

    init(
        metadata: ModelMetadata,
        predictionProvider: @escaping PredictionProvider
    ) {
        model = nil
        self.predictionProvider = predictionProvider
        self.metadata = metadata
    }

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try Task.checkCancellation()

        let hypotheses: [String: Double]
        do {
            if let predictionProvider {
                hypotheses = try predictionProvider(request.text)
            } else if let model {
                hypotheses = model.predictedLabelHypotheses(for: request.text, maximumCount: 2)
            } else {
                throw MLServiceError.modelUnavailable
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as MLServiceError {
            throw error
        } catch {
            throw MLServiceError.predictionFailed
        }

        try Task.checkCancellation()

        do {
            return try CoreMLPredictionMapper.map(hypotheses: hypotheses, metadata: metadata)
        } catch let error as CoreMLPredictionMappingError {
            switch error {
            case .missingPrediction:
                throw MLServiceError.predictionUnavailable
            case let .unsupportedLabel(label):
                throw MLServiceError.unsupportedLabel(label)
            case .invalidConfidence:
                throw MLServiceError.invalidPrediction
            }
        }
    }
}
