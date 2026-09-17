@main
enum TrainingCoreTests {
    static func main() throws {
        try PreparationTests.run()
        print("Training pipeline checks passed")
    }
}
