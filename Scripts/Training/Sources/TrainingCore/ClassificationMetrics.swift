struct LabeledPrediction: Codable, Equatable, Sendable {
    let expected: DatasetLabel
    let predicted: DatasetLabel
    var confidence: Double?
    var sampleID: String?

    init(
        expected: DatasetLabel,
        predicted: DatasetLabel,
        confidence: Double? = nil,
        sampleID: String? = nil
    ) {
        self.expected = expected
        self.predicted = predicted
        self.confidence = confidence
        self.sampleID = sampleID
    }
}

struct ConfusionMatrix: Codable, Equatable, Sendable {
    let truePositive: Int
    let trueNegative: Int
    let falsePositive: Int
    let falseNegative: Int
}

struct ClassificationMetrics: Codable, Equatable, Sendable {
    let sampleCount: Int
    let accuracy: Double
    let suspiciousPrecision: Double
    let suspiciousRecall: Double
    let suspiciousF1: Double
    let confusionMatrix: ConfusionMatrix

    init(predictions: [LabeledPrediction]) {
        let truePositive = predictions.count { $0.expected == .suspicious && $0.predicted == .suspicious }
        let trueNegative = predictions.count { $0.expected == .legitimate && $0.predicted == .legitimate }
        let falsePositive = predictions.count { $0.expected == .legitimate && $0.predicted == .suspicious }
        let falseNegative = predictions.count { $0.expected == .suspicious && $0.predicted == .legitimate }

        sampleCount = predictions.count
        accuracy = Self.ratio(truePositive + trueNegative, predictions.count)
        suspiciousPrecision = Self.ratio(truePositive, truePositive + falsePositive)
        suspiciousRecall = Self.ratio(truePositive, truePositive + falseNegative)
        suspiciousF1 = Self.harmonicMean(suspiciousPrecision, suspiciousRecall)
        confusionMatrix = ConfusionMatrix(
            truePositive: truePositive,
            trueNegative: trueNegative,
            falsePositive: falsePositive,
            falseNegative: falseNegative
        )
    }

    private static func ratio(_ numerator: Int, _ denominator: Int) -> Double {
        guard denominator > 0 else { return 0 }
        return Double(numerator) / Double(denominator)
    }

    private static func harmonicMean(_ lhs: Double, _ rhs: Double) -> Double {
        guard lhs + rhs > 0 else { return 0 }
        return 2 * lhs * rhs / (lhs + rhs)
    }
}
