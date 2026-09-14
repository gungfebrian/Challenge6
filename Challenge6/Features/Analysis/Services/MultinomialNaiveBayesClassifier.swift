//
//  MultinomialNaiveBayesClassifier.swift
//  Challenge6
//


import Foundation

struct MultinomialNaiveBayesClassifier: Sendable {
    struct TrainingExample: Sendable {
        let text: String
        let label: MessageLabel
    }

    private struct ClassStatistics: Sendable {
        var documentCount = 0
        var tokenCount = 0
        var countsByToken: [String: Int] = [:]

        mutating func observe(tokens: [String]) {
            documentCount += 1
            tokenCount += tokens.count

            for token in tokens {
                countsByToken[token, default: 0] += 1
            }
        }
    }

    private let suspicious: ClassStatistics
    private let legitimate: ClassStatistics
    private let vocabulary: Set<String>
    private let smoothing: Double

    init(trainingExamples: [TrainingExample], smoothing: Double = 1) {
        precondition(smoothing > 0, "Smoothing must be greater than zero.")  //laplace

        var suspicious = ClassStatistics()
        var legitimate = ClassStatistics()
        var vocabulary: Set<String> = []

        for example in trainingExamples { //trainingg
            let tokens = Self.tokenize(example.text)
            vocabulary.formUnion(tokens)

            switch example.label {
            case .suspicious:
                suspicious.observe(tokens: tokens)
            case .legitimate:
                legitimate.observe(tokens: tokens)
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

    func predict(text: String) -> AnalysisResult {
        let knownTokens = Self.tokenize(text).filter(vocabulary.contains)
        let documentCount = suspicious.documentCount + legitimate.documentCount

        let suspiciousScore = logScore(
            tokens: knownTokens,
            statistics: suspicious,
            totalDocumentCount: documentCount
        )
        let legitimateScore = logScore(
            tokens: knownTokens,
            statistics: legitimate,
            totalDocumentCount: documentCount
        )

        if suspiciousScore > legitimateScore {
            return AnalysisResult(
                label: .suspicious,
                confidence: normalizedWinningProbability(
                    winningScore: suspiciousScore,
                    losingScore: legitimateScore
                )
            )
        }

        return AnalysisResult(
            label: .legitimate,
            confidence: normalizedWinningProbability(
                winningScore: legitimateScore,
                losingScore: suspiciousScore
            )
        )
    }

    private func logScore( //the laplace smoothing
        tokens: [String],
        statistics: ClassStatistics,
        totalDocumentCount: Int
    ) -> Double {
        let prior = Double(statistics.documentCount) / Double(totalDocumentCount)
        let denominator = Double(statistics.tokenCount) + smoothing * Double(vocabulary.count)

        return tokens.reduce(log(prior)) { score, token in
            let observedCount = Double(statistics.countsByToken[token, default: 0])
            let likelihood = (observedCount + smoothing) / denominator
            return score + log(likelihood)
        }
    }

    private func normalizedWinningProbability(
        winningScore: Double,
        losingScore: Double
    ) -> Double {
        1 / (1 + exp(losingScore - winningScore))
    }

    private static func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
    }
}
