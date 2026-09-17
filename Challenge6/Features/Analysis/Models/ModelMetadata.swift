/// Stable model identity stored with every result so history remains interpretable after retraining.
struct ModelMetadata: Equatable, Sendable {
    let identifier: String
    let version: String
    let displayName: String

    static let coreMLMaxEnt = ModelMetadata(
        identifier: "SpamClassifierMaxEnt",
        version: "1.0.0",
        displayName: "Core ML MaxEnt"
    )

    static let educationalNaiveBayes = ModelMetadata(
        identifier: "MultinomialNaiveBayes",
        version: "learning-baseline-1",
        displayName: "Naive Bayes Learning Baseline"
    )

    static let deterministicDemo = ModelMetadata(
        identifier: "DeterministicDemo",
        version: "preview-1",
        displayName: "Preview Classifier"
    )
}
