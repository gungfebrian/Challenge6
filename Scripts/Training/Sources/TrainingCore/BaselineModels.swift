import Foundation

struct BaselinePrediction: Equatable, Sendable {
    let label: DatasetLabel
    let confidence: Double
}

struct MajorityClassBaseline: Sendable {
    private let label: DatasetLabel
    private let confidence: Double

    init(trainingSamples: [PreparedSample]) {
        let suspiciousCount = trainingSamples.count { $0.label == .suspicious }
        let legitimateCount = trainingSamples.count - suspiciousCount
        if suspiciousCount > legitimateCount {
            label = .suspicious
            confidence = Self.ratio(suspiciousCount, trainingSamples.count)
        } else {
            label = .legitimate
            confidence = Self.ratio(legitimateCount, trainingSamples.count)
        }
    }

    func predictions(for samples: [PreparedSample]) -> [LabeledPrediction] {
        samples.map {
            LabeledPrediction(
                expected: $0.label,
                predicted: label,
                confidence: confidence,
                sampleID: $0.sampleID
            )
        }
    }

    private static func ratio(_ numerator: Int, _ denominator: Int) -> Double {
        guard denominator > 0 else { return 0 }
        return Double(numerator) / Double(denominator)
    }
}

struct TransparentNaiveBayesBaseline: Sendable {
    private struct Statistics: Sendable {
        var documents = 0
        var tokenCount = 0
        var counts: [String: Int] = [:]

        mutating func observe(_ tokens: [String]) {
            documents += 1
            tokenCount += tokens.count
            for token in tokens {
                counts[token, default: 0] += 1
            }
        }
    }

    private let suspicious: Statistics
    private let legitimate: Statistics
    private let vocabulary: Set<String>

    init(trainingSamples: [PreparedSample]) {
        var suspicious = Statistics()
        var legitimate = Statistics()
        var vocabulary: Set<String> = []

        for sample in trainingSamples {
            let tokens = Self.tokens(in: sample.text)
            vocabulary.formUnion(tokens)
            switch sample.label {
            case .suspicious: suspicious.observe(tokens)
            case .legitimate: legitimate.observe(tokens)
            }
        }

        self.suspicious = suspicious
        self.legitimate = legitimate
        self.vocabulary = vocabulary
    }

    func predict(text: String) -> BaselinePrediction {
        let tokenCounts = Dictionary(grouping: Self.tokens(in: text).filter(vocabulary.contains), by: { $0 })
            .mapValues(\.count)
        let totalDocuments = suspicious.documents + legitimate.documents
        let suspiciousScore = score(tokenCounts, statistics: suspicious, totalDocuments: totalDocuments)
        let legitimateScore = score(tokenCounts, statistics: legitimate, totalDocuments: totalDocuments)

        if suspiciousScore > legitimateScore {
            return BaselinePrediction(
                label: .suspicious,
                confidence: Self.probability(winning: suspiciousScore, losing: legitimateScore)
            )
        }
        return BaselinePrediction(
            label: .legitimate,
            confidence: Self.probability(winning: legitimateScore, losing: suspiciousScore)
        )
    }

    func predictions(for samples: [PreparedSample]) -> [LabeledPrediction] {
        samples.map { sample in
            let prediction = predict(text: sample.text)
            return LabeledPrediction(
                expected: sample.label,
                predicted: prediction.label,
                confidence: prediction.confidence,
                sampleID: sample.sampleID
            )
        }
    }

    private func score(
        _ tokenCounts: [String: Int],
        statistics: Statistics,
        totalDocuments: Int
    ) -> Double {
        let prior = Double(statistics.documents) / Double(totalDocuments)
        let denominator = Double(statistics.tokenCount + vocabulary.count)
        return tokenCounts.reduce(log(prior)) { partial, entry in
            let likelihood = Double(statistics.counts[entry.key, default: 0] + 1) / denominator
            return partial + Double(entry.value) * log(likelihood)
        }
    }

    private static func tokens(in text: String) -> [String] {
        text.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init)
    }

    private static func probability(winning: Double, losing: Double) -> Double {
        1 / (1 + exp(losing - winning))
    }
}
