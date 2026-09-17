@main
enum TrainingCoreTests {
    static func main() throws {
        try PreparationTests.run()
        try SplittingAndMetricsTests.run()
        print("Training pipeline checks passed")
    }
}
