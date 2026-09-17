import Foundation

enum ReportWriter {
    static func markdown(record: ExperimentRecord) -> String {
        let evaluationRows = record.evaluations.map { evaluation in
            let metrics = evaluation.metrics
            let matrix = metrics.confusionMatrix
            return "| \(evaluation.name) | \(percent(metrics.accuracy)) | \(percent(metrics.suspiciousPrecision)) | \(percent(metrics.suspiciousRecall)) | \(percent(metrics.suspiciousF1)) | TP \(matrix.truePositive) / FP \(matrix.falsePositive) / TN \(matrix.trueNegative) / FN \(matrix.falseNegative) |"
        }.joined(separator: "\n")

        let splitRows = record.splitSummaries.map {
            "| \($0.name) | \($0.total) | \($0.suspicious) | \($0.legitimate) | \($0.groups) |"
        }.joined(separator: "\n")

        let errorRows = record.errorReviews.isEmpty
            ? "No incorrect predictions were available to review."
            : record.errorReviews.map {
                "| `\($0.sampleID)` | \($0.expected.rawValue) | \($0.predicted.rawValue) | \(percent($0.confidence)) | \($0.category) |"
            }.joined(separator: "\n")

        let demoRows = record.demoPredictions.isEmpty
            ? "No demo predictions were recorded."
            : record.demoPredictions.map {
                "| \($0.name) | \($0.predicted.rawValue) | \(percent($0.confidence)) |"
            }.joined(separator: "\n")

        return """
        # MaxEnt v1 Evaluation

        ## Experiment

        - Experiment: `\(record.experimentID)`
        - Created: \(record.createdAt)
        - Dataset: `\(record.datasetID)`
        - Source SHA-256: `\(record.sourceSHA256)`
        - Split seed: `\(record.splitSeed)`
        - Model: `\(record.modelIdentifier)` version `\(record.modelVersion)`
        - Algorithm: \(record.algorithm)
        - Language: \(record.language)
        - Training duration: \(decimal(record.trainingDurationSeconds)) seconds
        - Model size: \(record.modelSizeBytes) bytes
        - Median local inference latency: \(decimal(record.latencyMilliseconds)) ms

        ## Dataset and frozen split

        Total prepared samples: \(record.totalSamples). Exact and normalized duplicates are grouped before the deterministic stratified split.

        | Split | Total | Suspicious | Legitimate | Groups |
        |---|---:|---:|---:|---:|
        \(splitRows)

        Duplicate groups: \(record.duplicateSummary.duplicateGroupCount), containing \(record.duplicateSummary.duplicateSampleCount) samples.

        ## Measured results

        | Evaluation | Accuracy | Suspicious precision | Suspicious recall | Suspicious F1 | Confusion matrix |
        |---|---:|---:|---:|---:|---|
        \(evaluationRows)

        ## Incorrect holdout prediction review

        Source message text is intentionally omitted from the committed report. Stable sample identifiers allow a local reviewer with the ignored source corpus to reproduce the review.

        | Sample ID | Expected | Predicted | Confidence | Review category |
        |---|---|---|---:|---|
        \(errorRows)

        ## Demo messages

        | Example | Actual prediction | Confidence |
        |---|---|---:|
        \(demoRows)

        ## Interpretation

        Confidence is a model score, not certainty. This older English SMS benchmark does not represent all current scams, languages, regions, or conversational contexts. Results support an educational on-device demonstration and do not establish production readiness or safety advice.
        """
    }

    private static func percent(_ value: Double) -> String {
        String(format: "%.2f%%", value * 100)
    }

    private static func decimal(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
