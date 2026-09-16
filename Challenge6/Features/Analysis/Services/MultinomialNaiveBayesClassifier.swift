//
//  MultinomialNaiveBayesClassifier.swift
//  Challenge6
//

import Foundation

/// A local text classifier trained from labeled examples and represented by token counts.
struct MultinomialNaiveBayesClassifier: Sendable {
    /// One labeled document used to build the classifier's vocabulary and class statistics.
    struct TrainingExample: Sendable {
        let text: String
        let label: MessageLabel
    }

    private struct ClassStatistics: Sendable {
        var documentCount = 0
        var tokenCount = 0
        var countsByToken: [String: Int] = [:]

        mutating func observe(_ tokenBag: TokenBag) {
            documentCount += 1
            tokenCount += tokenBag.totalCount

            for (token, count) in tokenBag.counts {
                countsByToken[token, default: 0] += count
            }
        }
    }

    private let suspicious: ClassStatistics
    private let legitimate: ClassStatistics
    private let vocabulary: Set<String>
    private let smoothing: Double

    /// Trains the classifier once by aggregating the supplied examples per message label.
    init(trainingExamples: [TrainingExample], smoothing: Double = 1) {
        precondition(smoothing > 0, "Smoothing must be greater than zero.")

        var suspicious = ClassStatistics()
        var legitimate = ClassStatistics()
        var vocabulary: Set<String> = []

        for example in trainingExamples {
            let tokenBag = TokenBag(tokens: TextTokenizer.tokens(in: example.text))
            vocabulary.formUnion(tokenBag.counts.keys)

            switch example.label {
            case .suspicious:
                suspicious.observe(tokenBag)
            case .legitimate:
                legitimate.observe(tokenBag)
            }
        }

        precondition(
            suspicious.documentCount > 0 && legitimate.documentCount > 0,
            "Training data must contain both labels."
        )

        self.suspicious = suspicious
        self.legitimate = legitimate
        self.vocabulary = vocabulary
        self.smoothing = smoothing
    }

    /// Scores known input tokens against both labels and returns the stronger prediction.
    func predict(text: String) -> AnalysisResult {
        let knownTokenBag = TokenBag(tokens: TextTokenizer.tokens(in: text))
            .keeping(vocabulary)
        let documentCount = suspicious.documentCount + legitimate.documentCount

        let suspiciousScore = logScore(
            tokenBag: knownTokenBag,
            statistics: suspicious,
            totalDocumentCount: documentCount
        )
        let legitimateScore = logScore(
            tokenBag: knownTokenBag,
            statistics: legitimate,
            totalDocumentCount: documentCount
        )

        return PredictionScores(
            suspicious: suspiciousScore,
            legitimate: legitimateScore
        ).result
    }

    /// Combines a class prior with Laplace-smoothed token likelihoods in log space.
    private func logScore(
        tokenBag: TokenBag,
        statistics: ClassStatistics,
        totalDocumentCount: Int
    ) -> Double {
        let prior = Double(statistics.documentCount) / Double(totalDocumentCount)
        let denominator = Double(statistics.tokenCount) + smoothing * Double(vocabulary.count)

        return tokenBag.counts.reduce(log(prior)) { score, entry in
            let (token, frequency) = entry
            let observedCount = Double(statistics.countsByToken[token, default: 0])
            let likelihood = (observedCount + smoothing) / denominator
            return score + Double(frequency) * log(likelihood)
        }
    }

}
