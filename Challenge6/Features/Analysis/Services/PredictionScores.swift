import Foundation

struct PredictionScores: Sendable {
    let suspicious: Double
    let legitimate: Double

    var result: AnalysisResult {
        if suspicious > legitimate {
            return AnalysisResult(
                label: .suspicious,
                confidence: normalizedProbability(
                    winningScore: suspicious,
                    losingScore: legitimate
                )
            )
        }

        return AnalysisResult(
            label: .legitimate,
            confidence: normalizedProbability(
                winningScore: legitimate,
                losingScore: suspicious
            )
        )
    }

    private func normalizedProbability(
        winningScore: Double,
        losingScore: Double
    ) -> Double {
        1 / (1 + exp(losingScore - winningScore))
    }
}
