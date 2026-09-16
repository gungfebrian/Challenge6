@main
enum Challenge6CoreTests {
    static func main() async {
        await MultinomialNaiveBayesClassifierTests.run()

        print("Challenge6 checks passed")
    }
}
