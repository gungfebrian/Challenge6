import Foundation

enum PreparationTests {
    static func run() throws {
        try parsesEveryValidRowAndNormalizesLabels()
        rejectsMalformedRowsAsOneValidationFailure()
        sanitizesProhibitedIdentifiers()
        try producesStableNonRandomizedIdentifiers()
        try detectsNormalizedDuplicates()
        validatesPinnedSourceRequirements()
    }

    private static func parsesEveryValidRowAndNormalizesLabels() throws {
        let input = "ham\tProject sync is at ten\nspam\tClaim your reward now\n"
        let samples = try DatasetPreparer.prepare(data: Data(input.utf8), source: "uci")

        expect(samples.count == 2, "Every valid source row should become one prepared sample")
        expect(samples[0].label == .legitimate, "The ham label should map to legitimate")
        expect(samples[1].label == .suspicious, "The spam label should map to suspicious")
        expect(samples.allSatisfy { $0.source == "uci" }, "Prepared rows should retain controlled provenance")
        expect(samples.allSatisfy { $0.reviewStatus == .agreed }, "The published corpus labels should be recorded as agreed")
    }

    private static func rejectsMalformedRowsAsOneValidationFailure() {
        let input = "ham\tValid message\nunknown\tWrong label\nspam missing tab\n\tMissing label\n"

        expectThrows("Malformed rows should reject the dataset") {
            try DatasetPreparer.prepare(data: Data(input.utf8), source: "uci")
        } validate: { error in
            guard case let DatasetPreparationError.malformedRows(rows) = error else { return false }
            return rows == [2, 3, 4]
        }
    }

    private static func sanitizesProhibitedIdentifiers() {
        let input = "Email Alex.User+demo@example.com or call +1 (555) 123-4567. Visit https://example.com/pay?id=42, pay $1,200.50, account 12345678."
        let sanitized = TextSanitizer.sanitize(input)

        expect(!sanitized.contains("example.com"), "URLs and email domains should not remain in prepared text")
        expect(!sanitized.contains("555"), "Phone digits should not remain in prepared text")
        expect(!sanitized.contains("1,200"), "Amounts should not remain in prepared text")
        expect(!sanitized.contains("12345678"), "Account identifiers should not remain in prepared text")
        expect(sanitized.contains("<EMAIL>"), "Email addresses should use a stable placeholder")
        expect(sanitized.contains("<PHONE>"), "Phone numbers should use a stable placeholder")
        expect(sanitized.contains("<URL>"), "URLs should use a stable placeholder")
        expect(sanitized.contains("<AMOUNT>"), "Amounts should use a stable placeholder")
        expect(sanitized.contains("<ACCOUNT>"), "Account identifiers should use a stable placeholder")
    }

    private static func producesStableNonRandomizedIdentifiers() throws {
        expect(
            StableDigest.sha256("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
            "Stable identifiers should use the standard SHA-256 digest"
        )

        let input = "ham\tSame message\nham\tSame message\n"
        let first = try DatasetPreparer.prepare(data: Data(input.utf8), source: "uci")
        let second = try DatasetPreparer.prepare(data: Data(input.utf8), source: "uci")

        expect(first.map(\.sampleID) == second.map(\.sampleID), "Sample IDs should be reproducible")
        expect(Set(first.map(\.sampleID)).count == 2, "Each row should receive a unique sample ID")
        expect(first[0].groupID == first[1].groupID, "Exact duplicates should share a group ID")
    }

    private static func detectsNormalizedDuplicates() throws {
        let input = "ham\tMeet me at 10!\nham\t  meet   me at 10  \nspam\tWin cash\n"
        let samples = try DatasetPreparer.prepare(data: Data(input.utf8), source: "uci")
        let summary = DatasetPreparer.duplicateSummary(samples)

        expect(summary.duplicateGroupCount == 1, "Normalized duplicate groups should be counted")
        expect(summary.duplicateSampleCount == 2, "Every member of a duplicate group should be counted")
        expect(samples[0].groupID == samples[1].groupID, "Case, whitespace, and punctuation variants should remain in one group")
    }

    private static func validatesPinnedSourceRequirements() {
        let data = Data("ham\tOne\nspam\tTwo\n".utf8)
        let validManifest = DatasetManifest(
            datasetID: "fixture",
            title: "Fixture",
            version: "1",
            retrievedAt: "2026-09-17",
            canonicalPage: "https://example.invalid",
            downloadURL: "https://example.invalid/data.zip",
            archiveSHA256: "unused",
            dataFile: "fixture",
            dataFileSHA256: StableDigest.sha256(data),
            expectedRows: 2
        )

        expectThrows("A missing source file should fail validation") {
            try DatasetPreparer.validateSource(at: URL(fileURLWithPath: "/tmp/challenge6-missing-source"), manifest: validManifest)
        } validate: { $0 as? DatasetPreparationError == .sourceMissing }

        let wrongChecksum = DatasetManifest(
            datasetID: validManifest.datasetID,
            title: validManifest.title,
            version: validManifest.version,
            retrievedAt: validManifest.retrievedAt,
            canonicalPage: validManifest.canonicalPage,
            downloadURL: validManifest.downloadURL,
            archiveSHA256: validManifest.archiveSHA256,
            dataFile: validManifest.dataFile,
            dataFileSHA256: String(repeating: "0", count: 64),
            expectedRows: validManifest.expectedRows
        )
        let fixtureURL = FileManager.default.temporaryDirectory.appending(path: "challenge6-source-fixture-\(UUID().uuidString)")
        try? data.write(to: fixtureURL)
        defer { try? FileManager.default.removeItem(at: fixtureURL) }

        expectThrows("A checksum mismatch should fail validation") {
            try DatasetPreparer.validateSource(at: fixtureURL, manifest: wrongChecksum)
        } validate: { $0 as? DatasetPreparationError == .checksumMismatch }

        let wrongCount = DatasetManifest(
            datasetID: validManifest.datasetID,
            title: validManifest.title,
            version: validManifest.version,
            retrievedAt: validManifest.retrievedAt,
            canonicalPage: validManifest.canonicalPage,
            downloadURL: validManifest.downloadURL,
            archiveSHA256: validManifest.archiveSHA256,
            dataFile: validManifest.dataFile,
            dataFileSHA256: validManifest.dataFileSHA256,
            expectedRows: 3
        )

        expectThrows("An unexpected row count should fail validation") {
            try DatasetPreparer.validateSource(at: fixtureURL, manifest: wrongCount)
        } validate: { $0 as? DatasetPreparationError == .rowCountMismatch(expected: 3, actual: 2) }
    }
}
