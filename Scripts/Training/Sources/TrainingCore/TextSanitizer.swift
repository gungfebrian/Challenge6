import Foundation

enum TextSanitizer {
    private struct Replacement {
        let expression: NSRegularExpression
        let placeholder: String

        init(_ pattern: String, placeholder: String, options: NSRegularExpression.Options = []) {
            expression = try! NSRegularExpression(pattern: pattern, options: options)
            self.placeholder = placeholder
        }
    }

    // Ordering is intentional: broad numeric patterns run only after contextual identifiers.
    private static let replacements: [Replacement] = [
        Replacement(#"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b"#, placeholder: "<EMAIL>", options: .caseInsensitive),
        Replacement(#"(?:\b(?:https?://|www\.)[^\s,]+|\b[A-Z0-9.-]+\.(?:com|co\.uk|org|net|io|me)(?:/[^\s,]*)?)"#, placeholder: "<URL>", options: .caseInsensitive),
        Replacement(#"\b(?:account|acct|a/c|password|passcode|pin|otp)\s*(?:number|no\.?|#|is)?\s*[:=-]?\s*[A-Z0-9-]{4,}\b"#, placeholder: "<ACCOUNT>", options: .caseInsensitive),
        Replacement(#"(?:[$£€₹]\s?\d[\d,.]*|\b(?:USD|GBP|EUR|INR)\s?\d[\d,.]*|\b\d[\d,.]*\s?(?:USD|GBP|EUR|INR)\b|\b\d+(?:[.,]\d+)?p(?=\b|/))"#, placeholder: "<AMOUNT>", options: .caseInsensitive),
        Replacement(#"(?<![A-Z0-9])\+?\d(?:[\s().-]*\d){4,}(?:p)?(?![A-Z0-9])"#, placeholder: "<PHONE>", options: .caseInsensitive)
    ]

    static func sanitize(_ text: String) -> String {
        let sanitized = replacements.reduce(text) { current, replacement in
            let range = NSRange(current.startIndex..., in: current)
            return replacement.expression.stringByReplacingMatches(
                in: current,
                range: range,
                withTemplate: replacement.placeholder
            )
        }

        return sanitized
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    static func normalizedForGrouping(_ text: String) -> String {
        let alphanumericText = text
            .lowercased()
            .unicodeScalars
            .map { CharacterSet.alphanumerics.contains($0) ? String($0) : " " }
            .joined()

        return alphanumericText
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .joined(separator: " ")
    }
}
