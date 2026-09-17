enum CoreMLPredictionMappingError: Error, Equatable, Sendable {
    case missingPrediction
    case unsupportedLabel(String)
    case invalidConfidence
}

enum CoreMLPredictionMapper {
    static func map(
        hypotheses: [String: Double],
        metadata: ModelMetadata
    ) throws -> AnalysisResult {
        guard !hypotheses.isEmpty else {
            throw CoreMLPredictionMappingError.missingPrediction
        }

        for (label, score) in hypotheses {
            guard score.isFinite else {
                throw CoreMLPredictionMappingError.invalidConfidence
            }
            guard MessageLabel(rawValue: label) != nil else {
                throw CoreMLPredictionMappingError.unsupportedLabel(label)
            }
        }

        guard let winner = hypotheses.sorted(by: {
            if $0.value == $1.value { return $0.key < $1.key }
            return $0.value > $1.value
        }).first else {
            throw CoreMLPredictionMappingError.missingPrediction
        }
        guard let label = MessageLabel(rawValue: winner.key) else {
            throw CoreMLPredictionMappingError.unsupportedLabel(winner.key)
        }

        return AnalysisResult(
            label: label,
            confidence: min(max(winner.value, 0), 1),
            model: metadata
        )
    }
}
