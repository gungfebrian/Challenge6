enum TrainingDataValidatorTests {
    static func run() {
        expect(
            TrainingDataValidator.issue(examples: [], smoothing: 1) == .missingSuspiciousLabel,
            "Training data should require suspicious examples"
        )
        expect(
            TrainingDataValidator.issue(
                examples: [.init(text: "spam", label: .suspicious)],
                smoothing: 1
            ) == .missingLegitimateLabel,
            "Training data should require legitimate examples"
        )
        expect(
            TrainingDataValidator.issue(
                examples: SpamTrainingDataset.examples,
                smoothing: 0
            ) == .nonPositiveSmoothing,
            "Training data should require positive smoothing"
        )
        for smoothing in [Double.nan, .infinity] {
            expect(
                TrainingDataValidator.issue(
                    examples: SpamTrainingDataset.examples,
                    smoothing: smoothing
                ) == .nonPositiveSmoothing,
                "Training data should reject non-finite smoothing"
            )
        }
        expect(
            TrainingDataValidator.issue(
                examples: SpamTrainingDataset.examples,
                smoothing: 1
            ) == nil,
            "The bundled training data should be valid"
        )
    }
}
