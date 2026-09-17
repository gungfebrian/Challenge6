import Foundation

enum DatasetPreparer {
    static func loadManifest(at url: URL) throws -> DatasetManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(DatasetManifest.self, from: data)
    }

    @discardableResult
    static func validateSource(at url: URL, manifest: DatasetManifest) throws -> Data {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DatasetPreparationError.sourceMissing
        }
        guard let data = try? Data(contentsOf: url) else {
            throw DatasetPreparationError.unreadableSource
        }
        guard StableDigest.sha256(data) == manifest.dataFileSHA256 else {
            throw DatasetPreparationError.checksumMismatch
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw DatasetPreparationError.invalidUTF8
        }

        let rowCount = sourceLines(in: text).count
        guard rowCount == manifest.expectedRows else {
            throw DatasetPreparationError.rowCountMismatch(expected: manifest.expectedRows, actual: rowCount)
        }

        return data
    }

    static func prepare(data: Data, source: String) throws -> [PreparedSample] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw DatasetPreparationError.invalidUTF8
        }

        var malformedRows: [Int] = []
        var parsedRows: [(label: DatasetLabel, text: String)] = []

        for (offset, rawLine) in sourceLines(in: text).enumerated() {
            let rowNumber = offset + 1
            guard let tab = rawLine.firstIndex(of: "\t") else {
                malformedRows.append(rowNumber)
                continue
            }

            let rawLabel = String(rawLine[..<tab])
            let messageStart = rawLine.index(after: tab)
            let rawMessage = String(rawLine[messageStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let label = normalizedLabel(rawLabel), !rawMessage.isEmpty else {
                malformedRows.append(rowNumber)
                continue
            }

            parsedRows.append((label, rawMessage))
        }

        guard malformedRows.isEmpty else {
            throw DatasetPreparationError.malformedRows(malformedRows)
        }

        var occurrenceByFingerprint: [String: Int] = [:]
        return parsedRows.map { row in
            let sanitizedText = TextSanitizer.sanitize(row.text)
            let normalizedText = TextSanitizer.normalizedForGrouping(sanitizedText)
            let fingerprint = "\(row.label.rawValue)\u{0}\(sanitizedText)"
            let occurrence = occurrenceByFingerprint[fingerprint, default: 0]
            occurrenceByFingerprint[fingerprint] = occurrence + 1

            return PreparedSample(
                sampleID: StableDigest.sha256("sample\u{0}\(fingerprint)\u{0}\(occurrence)"),
                text: sanitizedText,
                label: row.label,
                groupID: StableDigest.sha256("group\u{0}\(normalizedText)"),
                source: source,
                reviewStatus: .agreed
            )
        }
    }

    static func duplicateSummary(_ samples: [PreparedSample]) -> DuplicateSummary {
        let counts = Dictionary(grouping: samples, by: \.groupID).mapValues(\.count)
        let duplicateCounts = counts.values.filter { $0 > 1 }
        return DuplicateSummary(
            duplicateGroupCount: duplicateCounts.count,
            duplicateSampleCount: duplicateCounts.reduce(0, +)
        )
    }

    private static func normalizedLabel(_ value: String) -> DatasetLabel? {
        switch value.lowercased() {
        case "spam": .suspicious
        case "ham": .legitimate
        default: nil
        }
    }

    private static func sourceLines(in text: String) -> [Substring] {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        if lines.last?.isEmpty == true {
            lines.removeLast()
        }
        return lines
    }
}
