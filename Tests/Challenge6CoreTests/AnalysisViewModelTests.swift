enum AnalysisViewModelTests {
    @MainActor
    static func run() async {
        let viewModel = AnalysisViewModel(mlService: UnexpectedCallService())
        viewModel.message = "   \n"

        await viewModel.analyze()

        expect(
            viewModel.state == .failure(.emptyInput),
            "Blank input should produce a typed empty-input failure"
        )
    }
}

private struct UnexpectedCallService: MLService {
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        fatalError("The ML service should not receive blank input")
    }
}
