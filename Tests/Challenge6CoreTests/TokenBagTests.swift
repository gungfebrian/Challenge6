enum TokenBagTests {
    static func run() {
        let bag = TokenBag(tokens: ["cash", "meeting", "cash"])

        expect(
            bag.counts == ["cash": 2, "meeting": 1],
            "TokenBag should count repeated tokens"
        )
        expect(bag.totalCount == 3, "TokenBag should retain the total token count")
        expect(
            bag.keeping(["cash"]).counts == ["cash": 2],
            "TokenBag should keep only vocabulary tokens"
        )
    }
}
