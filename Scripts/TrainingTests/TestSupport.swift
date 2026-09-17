import Foundation

func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fatalError(message)
    }
}

func expectThrows<T>(
    _ message: String,
    operation: () throws -> T,
    validate: (Error) -> Bool
) {
    do {
        _ = try operation()
        fatalError(message)
    } catch {
        expect(validate(error), "Unexpected error for \(message): \(error)")
    }
}
