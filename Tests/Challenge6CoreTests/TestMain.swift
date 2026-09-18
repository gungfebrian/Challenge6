@main
enum Challenge6CoreTests {
    static func main() async {
        TextTokenizerTests.run()
        TokenBagTests.run()
        PredictionScoresTests.run()
        TrainingDataValidatorTests.run()
        AnalysisRequestTests.run()
        CoreMLPredictionMapperTests.run()
        await MultinomialNaiveBayesClassifierTests.run()
        await CoreMLServiceContractTests.run()
        await AnalysisViewModelTests.run()
        HistoryRetentionPolicyTests.run()
        AppPreferencesTests.run()
        AnalysisPresentationPolicyTests.run()
        try! SwiftDataHistoryStoreTests.run()

        print("Challenge6 checks passed")
    }
}
