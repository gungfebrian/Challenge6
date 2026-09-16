enum AnalysisRequestTests {
    static func run() {
        expect(
            AnalysisRequest(rawText: "  hello\n")?.text == "hello",
            "Analysis requests should trim surrounding whitespace"
        )
        expect(
            AnalysisRequest(rawText: "  \n") == nil,
            "Analysis requests should reject blank input"
        )
    }
}
