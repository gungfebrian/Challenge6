struct DemoExample: Identifiable {
    enum Kind: String {
        case suspicious = "Suspicious"
        case legitimate = "Legitimate"
        case ambiguous = "Ambiguous"
    }

    let kind: Kind
    let message: String
    let systemImage: String

    var id: Kind { kind }

    static let all: [DemoExample] = [
        DemoExample(
            kind: .suspicious,
            message: "URGENT! Your mobile number has won a $5,000 cash prize. Click now to verify and claim your reward.",
            systemImage: "exclamationmark.bubble"
        ),
        DemoExample(
            kind: .legitimate,
            message: "Hi Maya, our project meeting is at 10:30 tomorrow in the library. Please bring the latest notes.",
            systemImage: "person.2"
        ),
        DemoExample(
            kind: .ambiguous,
            message: "Urgent: verify the delivery link at portal.example/check.",
            systemImage: "questionmark.bubble"
        )
    ]
}
