enum TextTokenizerTests {
    static func run() {
        expect(
            TextTokenizer.tokens(in: "URGENT! click-now 42") == ["urgent", "click", "now", "42"],
            "Tokenizer should normalize case and split punctuation"
        )
    }
}
