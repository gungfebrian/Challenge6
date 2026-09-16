@main
enum Challenge6CoreTests {
    static func main() async {
        TextTokenizerTests.run()
        TokenBagTests.run()
        PredictionScoresTests.run()
        await MultinomialNaiveBayesClassifierTests.run()

        print("Challenge6 checks passed")
    }
}
