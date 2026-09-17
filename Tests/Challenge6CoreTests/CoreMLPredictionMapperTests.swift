enum CoreMLPredictionMapperTests {
    static func run() {
        let metadata = ModelMetadata(
            identifier: "SpamClassifierMaxEnt",
            version: "1.0.0",
            displayName: "Core ML MaxEnt"
        )

        do {
            let suspicious = try CoreMLPredictionMapper.map(
                hypotheses: ["suspicious": 0.82, "legitimate": 0.18],
                metadata: metadata
            )
            expect(suspicious.label == .suspicious, "The suspicious Core ML label should map explicitly")
            expectApproximatelyEqual(suspicious.confidence, 0.82, "The winning suspicious probability should become confidence")
            expect(suspicious.model == metadata, "The result should identify the model that produced it")

            let legitimate = try CoreMLPredictionMapper.map(
                hypotheses: ["suspicious": 0.09, "legitimate": 0.91],
                metadata: metadata
            )
            expect(legitimate.label == .legitimate, "The legitimate Core ML label should map explicitly")
            expectApproximatelyEqual(legitimate.confidence, 0.91, "The winning legitimate probability should become confidence")

            let clamped = try CoreMLPredictionMapper.map(
                hypotheses: ["suspicious": 1.000_001, "legitimate": 0],
                metadata: metadata
            )
            expect(clamped.confidence == 1, "A finite floating-point overshoot should be clamped into the probability range")
        } catch {
            fatalError("Valid Core ML hypotheses should map: \(error)")
        }

        expectThrows("An unknown winning label should be rejected") {
            try CoreMLPredictionMapper.map(hypotheses: ["unknown": 0.9], metadata: metadata)
        } validate: { $0 as? CoreMLPredictionMappingError == .unsupportedLabel("unknown") }

        expectThrows("Missing hypotheses should be rejected") {
            try CoreMLPredictionMapper.map(hypotheses: [:], metadata: metadata)
        } validate: { $0 as? CoreMLPredictionMappingError == .missingPrediction }

        expectThrows("A non-finite confidence should be rejected") {
            try CoreMLPredictionMapper.map(hypotheses: ["suspicious": .nan], metadata: metadata)
        } validate: { $0 as? CoreMLPredictionMappingError == .invalidConfidence }
    }
}
