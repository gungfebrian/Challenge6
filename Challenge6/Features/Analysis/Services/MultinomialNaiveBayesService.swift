//
//  MultinomialNaiveBayesService.swift
//  Challenge6
//

/// Adapts the app's ML service contract to the local multinomial Naive Bayes classifier.
struct MultinomialNaiveBayesService: MLService {
    private let classifier: MultinomialNaiveBayesClassifier

    init(
        trainingExamples: [MultinomialNaiveBayesClassifier.TrainingExample] = Self.learningExamples
    ) {
        classifier = MultinomialNaiveBayesClassifier(trainingExamples: trainingExamples)
    }

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try Task.checkCancellation()
        return classifier.predict(text: request.text)
    }

    private static let learningExamples: [MultinomialNaiveBayesClassifier.TrainingExample] = [
        .init(
            text: "Congratulations winner claim your cash prize click the link now",
            label: .suspicious
        ),
        .init(
            text: "Urgent verify your bank account password immediately",
            label: .suspicious
        ),
        .init(
            text: "Limited offer get a free gift claim today",
            label: .suspicious
        ),
        .init(
            text: "Your package is held pay the delivery fee now",
            label: .suspicious
        ),
        .init(
            text: "Act now to avoid account suspension click to verify",
            label: .suspicious
        ),
        .init(
            text: "You are selected as a winner send your personal details",
            label: .suspicious
        ),
        .init(
            text: "Can we move our team meeting to tomorrow morning",
            label: .legitimate
        ),
        .init(
            text: "Dinner is ready see you at home tonight",
            label: .legitimate
        ),
        .init(
            text: "Your dentist appointment is Tuesday at ten",
            label: .legitimate
        ),
        .init(
            text: "Thanks for sending the project notes",
            label: .legitimate
        ),
        .init(
            text: "Please review the document before our class",
            label: .legitimate
        ),
        .init(
            text: "Remember to buy milk and bread on your way home",
            label: .legitimate
        )
    ]
}
