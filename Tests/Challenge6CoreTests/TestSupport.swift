func expect(
    _ condition: @autoclosure () -> Bool,
    _ message: String
) {
    guard condition() else {
        fatalError(message)
    }
}

func expectApproximatelyEqual(
    _ actual: Double,
    _ expected: Double,
    _ message: String,
    tolerance: Double = 0.000_001
) {
    expect(abs(actual - expected) < tolerance, message)
}
