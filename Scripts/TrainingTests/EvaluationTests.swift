import Foundation

enum EvaluationTests {
    static func run() throws {
        majorityBaselineUsesOnlyTrainingDistribution()
        transparentBaselineLearnsTokenCounts()
        reportRendersMeasuredMetricsAndMetadata()
    }

    private static func majorityBaselineUsesOnlyTrainingDistribution() {
        let training = [
            sample("l1", "Team meeting", .legitimate),
            sample("l2", "Dentist tomorrow", .legitimate),
            sample("s1", "Claim cash", .suspicious)
        ]
        let model = MajorityClassBaseline(trainingSamples: training)
        let predictions = model.predictions(for: [
            sample("h1", "Unknown one", .legitimate),
            sample("h2", "Unknown two", .suspicious)
        ])
        let metrics = ClassificationMetrics(predictions: predictions)

        expect(predictions.allSatisfy { $0.predicted == .legitimate }, "The majority baseline should always use the training majority label")
        expectApproximatelyEqual(metrics.accuracy, 0.5, "Metrics should be derived from the baseline's actual holdout predictions")
        expect(metrics.confusionMatrix.falseNegative == 1, "The suspicious holdout row should be a measured false negative")
    }

    private static func transparentBaselineLearnsTokenCounts() {
        let model = TransparentNaiveBayesBaseline(trainingSamples: [
            sample("s1", "cash prize claim", .suspicious),
            sample("s2", "urgent cash reward", .suspicious),
            sample("l1", "project meeting notes", .legitimate),
            sample("l2", "meeting tomorrow class", .legitimate)
        ])

        expect(model.predict(text: "urgent cash").label == .suspicious, "Suspicious token evidence should select the suspicious baseline label")
        expect(model.predict(text: "project meeting").label == .legitimate, "Legitimate token evidence should select the legitimate baseline label")
        expect(model.predict(text: "unseen vocabulary").confidence == 0.5, "Equal priors and unseen words should preserve the documented legitimate tie")
    }

    private static func reportRendersMeasuredMetricsAndMetadata() {
        let metrics = ClassificationMetrics(predictions: [
            LabeledPrediction(expected: .suspicious, predicted: .suspicious),
            LabeledPrediction(expected: .legitimate, predicted: .legitimate),
            LabeledPrediction(expected: .legitimate, predicted: .suspicious),
            LabeledPrediction(expected: .suspicious, predicted: .legitimate)
        ])
        let record = ExperimentRecord(
            experimentID: "maxent-v1",
            createdAt: "2026-09-17T00:00:00Z",
            datasetID: "fixture-v1",
            sourceSHA256: "abc123",
            splitSeed: 42,
            modelIdentifier: "SpamClassifierMaxEnt",
            modelVersion: "1.0.0",
            algorithm: "Maximum Entropy",
            language: "English",
            trainingDurationSeconds: 1.25,
            modelSizeBytes: 4096,
            latencyMilliseconds: 2.5,
            totalSamples: 4,
            duplicateSummary: DuplicateSummary(duplicateGroupCount: 1, duplicateSampleCount: 2),
            splitSummaries: [
                SplitSummary(name: "holdout", total: 4, suspicious: 2, legitimate: 2, groups: 4)
            ],
            evaluations: [EvaluationRecord(name: "MaxEnt holdout", metrics: metrics)],
            errorReviews: [
                ErrorReview(sampleID: "sample-1", expected: .suspicious, predicted: .legitimate, confidence: 0.6, category: "Limited context")
            ],
            demoPredictions: []
        )
        let report = ReportWriter.markdown(record: record)

        expect(report.contains("maxent-v1"), "The report should identify the immutable experiment")
        expect(report.contains("75.00%") == false, "The report should not invent accuracy unrelated to supplied predictions")
        expect(report.contains("50.00%"), "The report should render the measured accuracy from two correct predictions out of four")
        expect(report.contains("1.250 seconds"), "The English report should use a stable decimal point for duration")
        expect(report.contains("2.500 ms"), "The English report should use a stable decimal point for latency")
        expect(report.contains("TP 1 / FP 1 / TN 1 / FN 1"), "The report should render the measured confusion matrix")
        expect(report.contains("sample-1"), "Error review should retain a stable non-message identifier")
        expect(!report.contains("Unknown one"), "Evaluation reports should not copy source message text")

        let encoded = try? JSONEncoder().encode(record)
        let decoded = encoded.flatMap { try? JSONDecoder().decode(ExperimentRecord.self, from: $0) }
        expect(decoded == record, "The structured experiment record should round-trip through JSON")
    }

    private static func sample(_ id: String, _ text: String, _ label: DatasetLabel) -> PreparedSample {
        PreparedSample(
            sampleID: id,
            text: text,
            label: label,
            groupID: "group-\(id)",
            source: "fixture",
            reviewStatus: .agreed
        )
    }
}
