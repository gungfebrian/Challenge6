//
//  MultinomialNaiveBayesService.swift
//  Challenge6
//

/// Adapts the app's ML service contract to the local multinomial Naive Bayes classifier.
struct MultinomialNaiveBayesService: MLService {
    private let classifier: MultinomialNaiveBayesClassifier

    init(
        trainingExamples: [MultinomialNaiveBayesClassifier.TrainingExample] = SpamTrainingDataset.examples
    ) {
        classifier = MultinomialNaiveBayesClassifier(trainingExamples: trainingExamples)
    }

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try Task.checkCancellation()
        return classifier.predict(text: request.text)
    }

}
