enum TrainingDataIssue: Equatable, Sendable {
    case nonPositiveSmoothing
    case missingSuspiciousLabel
    case missingLegitimateLabel

    var message: String {
        switch self {
        case .nonPositiveSmoothing:
            "Smoothing must be greater than zero."
        case .missingSuspiciousLabel, .missingLegitimateLabel:
            "Training data must contain both labels."
        }
    }
}

enum TrainingDataValidator {
    static func issue(
        examples: [MultinomialNaiveBayesClassifier.TrainingExample],
        smoothing: Double
    ) -> TrainingDataIssue? {
        guard smoothing > 0 else {
            return .nonPositiveSmoothing
        }

        guard examples.contains(where: { $0.label == .suspicious }) else {
            return .missingSuspiciousLabel
        }

        guard examples.contains(where: { $0.label == .legitimate }) else {
            return .missingLegitimateLabel
        }

        return nil
    }
}
