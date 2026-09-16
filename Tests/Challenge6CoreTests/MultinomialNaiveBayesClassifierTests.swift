import Foundation

enum MultinomialNaiveBayesClassifierTests {
    static func run() async {
        let classifier = MultinomialNaiveBayesClassifier(
            trainingExamples: [
                .init(text: "win cash cash", label: .suspicious),
                .init(text: "team meeting", label: .legitimate)
            ]
        )

        let prediction = classifier.predict(text: "cash cash")
        expect(
            prediction.label == .suspicious,
            "Repeated suspicious words should produce a suspicious label"
        )
        expectApproximatelyEqual(
            prediction.confidence,
            324.0 / 373.0,
            "Confidence should match the hand-calculated Laplace-smoothed probability"
        )

        let plainPrediction = classifier.predict(text: "cash cash")
        let noisyPrediction = classifier.predict(text: "CASH!!! cash.")
        expect(
            noisyPrediction == plainPrediction,
            "Tokenization should ignore letter case and punctuation"
        )

        let legitimatePrediction = classifier.predict(text: "team meeting")
        expect(
            legitimatePrediction.label == .legitimate,
            "Legitimate vocabulary should produce a legitimate label"
        )
        expect(
            legitimatePrediction.confidence > 0.5 && legitimatePrediction.confidence <= 1,
            "Confidence should be a probability for the predicted label"
        )

        await checkLearningServiceExamples()

    }

    private static func checkLearningServiceExamples() async {
        let service = MultinomialNaiveBayesService()

        do {
            let suspiciousResult = try await service.analyze(
                AnalysisRequest(text: "Urgent! Click here to claim your cash prize")
            )
            expect(
                suspiciousResult.label == .suspicious,
                "The learning service should recognize a representative suspicious message"
            )

            let legitimateResult = try await service.analyze(
                AnalysisRequest(text: "Can we move our team meeting to tomorrow morning?")
            )
            expect(
                legitimateResult.label == .legitimate,
                "The learning service should recognize a representative legitimate message"
            )
        } catch {
            fatalError("The local learning service should not throw: \(error)")
        }
    }

}
