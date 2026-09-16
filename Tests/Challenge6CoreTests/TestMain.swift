@main
enum Challenge6CoreTests {
    static func main() async {
        TextTokenizerTests.run()
        TokenBagTests.run()
        PredictionScoresTests.run()
        TrainingDataValidatorTests.run()
        AnalysisRequestTests.run()
        await MultinomialNaiveBayesClassifierTests.run()

        print("Challenge6 checks passed")
    }
}
