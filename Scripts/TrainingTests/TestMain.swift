@main
enum TrainingCoreTests {
    static func main() throws {
        try PreparationTests.run()
        try SplittingAndMetricsTests.run()
        try EvaluationTests.run()
        print("Training pipeline checks passed")
    }
}
