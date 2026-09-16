struct TokenBag: Equatable, Sendable {
    let counts: [String: Int]

    var totalCount: Int {
        counts.values.reduce(0, +)
    }

    init(tokens: [String]) {
        counts = tokens.reduce(into: [:]) { counts, token in
            counts[token, default: 0] += 1
        }
    }

    private init(counts: [String: Int]) {
        self.counts = counts
    }

    func keeping(_ vocabulary: Set<String>) -> TokenBag {
        TokenBag(counts: counts.filter { vocabulary.contains($0.key) })
    }
}
