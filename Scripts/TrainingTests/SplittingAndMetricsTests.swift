import Foundation

enum SplittingAndMetricsTests {
    static func run() throws {
        try splitIsDeterministicAndStratified()
        try duplicateGroupsNeverCrossSplits()
        rejectsConflictingLabelsWithinOneGroup()
        computesMetricsFromLiteralPredictions()
    }

    private static func splitIsDeterministicAndStratified() throws {
        let samples = fixtureSamples(perLabel: 40)
        let first = try GroupedSplitter.split(samples, seed: 20_260_917)
        let second = try GroupedSplitter.split(samples, seed: 20_260_917)

        expect(first == second, "A fixed seed should reproduce the same split")
        try first.validate(originalSamples: samples)

        for label in DatasetLabel.allCases {
            let trainCount = first.training.filter { $0.label == label }.count
            let validationCount = first.validation.filter { $0.label == label }.count
            let holdoutCount = first.holdout.filter { $0.label == label }.count

            expect(trainCount == 28, "Each label should place 70 percent of fixture samples in training")
            expect(validationCount == 6, "Each label should place 15 percent of fixture samples in validation")
            expect(holdoutCount == 6, "Each label should place 15 percent of fixture samples in holdout")
        }

        let alternate = try GroupedSplitter.split(samples, seed: 20_260_918)
        expect(
            first.training.map(\.sampleID) != alternate.training.map(\.sampleID),
            "Changing the recorded seed should change sample assignments"
        )
    }

    private static func duplicateGroupsNeverCrossSplits() throws {
        var samples = fixtureSamples(perLabel: 12)
        samples.append(
            PreparedSample(
                sampleID: "duplicate-a",
                text: "Same template",
                label: .suspicious,
                groupID: "shared-template",
                source: "fixture",
                reviewStatus: .agreed
            )
        )
        samples.append(
            PreparedSample(
                sampleID: "duplicate-b",
                text: "Same template!",
                label: .suspicious,
                groupID: "shared-template",
                source: "fixture",
                reviewStatus: .agreed
            )
        )

        let split = try GroupedSplitter.split(samples, seed: 42)
        try split.validate(originalSamples: samples)
        let containingSplitCount = [split.training, split.validation, split.holdout]
            .filter { partition in partition.contains { $0.groupID == "shared-template" } }
            .count

        expect(containingSplitCount == 1, "Every member of a duplicate group should remain in one split")
    }

    private static func rejectsConflictingLabelsWithinOneGroup() {
        let samples = [
            PreparedSample(sampleID: "a", text: "same", label: .suspicious, groupID: "group", source: "fixture", reviewStatus: .agreed),
            PreparedSample(sampleID: "b", text: "same", label: .legitimate, groupID: "group", source: "fixture", reviewStatus: .agreed)
        ]

        expectThrows("A group with conflicting labels should be rejected") {
            try GroupedSplitter.split(samples, seed: 1)
        } validate: { $0 as? DatasetSplitError == .conflictingLabels(groupID: "group") }
    }

    private static func computesMetricsFromLiteralPredictions() {
        let predictions = [
            LabeledPrediction(expected: .suspicious, predicted: .suspicious),
            LabeledPrediction(expected: .suspicious, predicted: .suspicious),
            LabeledPrediction(expected: .suspicious, predicted: .legitimate),
            LabeledPrediction(expected: .legitimate, predicted: .suspicious),
            LabeledPrediction(expected: .legitimate, predicted: .legitimate),
            LabeledPrediction(expected: .legitimate, predicted: .legitimate),
            LabeledPrediction(expected: .legitimate, predicted: .legitimate),
            LabeledPrediction(expected: .legitimate, predicted: .legitimate)
        ]
        let metrics = ClassificationMetrics(predictions: predictions)

        expect(metrics.confusionMatrix.truePositive == 2, "Suspicious matches should count as true positives")
        expect(metrics.confusionMatrix.falseNegative == 1, "Missed suspicious rows should count as false negatives")
        expect(metrics.confusionMatrix.falsePositive == 1, "Incorrect warnings should count as false positives")
        expect(metrics.confusionMatrix.trueNegative == 4, "Legitimate matches should count as true negatives")
        expectApproximatelyEqual(metrics.accuracy, 0.75, "Accuracy should come from six correct predictions out of eight")
        expectApproximatelyEqual(metrics.suspiciousPrecision, 2.0 / 3.0, "Precision should be TP divided by TP plus FP")
        expectApproximatelyEqual(metrics.suspiciousRecall, 2.0 / 3.0, "Recall should be TP divided by TP plus FN")
        expectApproximatelyEqual(metrics.suspiciousF1, 2.0 / 3.0, "F1 should be the harmonic mean of precision and recall")

        let noSuspiciousPredictions = ClassificationMetrics(
            predictions: [LabeledPrediction(expected: .legitimate, predicted: .legitimate)]
        )
        expect(noSuspiciousPredictions.suspiciousPrecision == 0, "A zero precision denominator should produce a finite zero")
        expect(noSuspiciousPredictions.suspiciousRecall == 0, "A zero recall denominator should produce a finite zero")
        expect(noSuspiciousPredictions.suspiciousF1 == 0, "A zero F1 denominator should produce a finite zero")
    }

    private static func fixtureSamples(perLabel: Int) -> [PreparedSample] {
        DatasetLabel.allCases.flatMap { label in
            (0..<perLabel).map { index in
                PreparedSample(
                    sampleID: "\(label.rawValue)-\(index)",
                    text: "\(label.rawValue) message \(index)",
                    label: label,
                    groupID: "\(label.rawValue)-group-\(index)",
                    source: "fixture",
                    reviewStatus: .agreed
                )
            }
        }
    }
}
