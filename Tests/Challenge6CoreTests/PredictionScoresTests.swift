enum PredictionScoresTests {
    static func run() {
        let suspiciousResult = PredictionScores(suspicious: 2, legitimate: 1).result
        expect(
            suspiciousResult.label == .suspicious,
            "The higher suspicious score should select the suspicious label"
        )
        expectApproximatelyEqual(
            suspiciousResult.confidence,
            0.731_058_578_630_004_9,
            "Winning scores should be normalized into confidence"
        )

        let tiedResult = PredictionScores(suspicious: 1, legitimate: 1).result
        expect(
            tiedResult == AnalysisResult(label: .legitimate, confidence: 0.5),
            "Tied scores should preserve the existing legitimate fallback"
        )
    }
}
