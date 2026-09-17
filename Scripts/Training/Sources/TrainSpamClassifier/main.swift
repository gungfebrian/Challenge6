import CoreML
import CreateML
import Foundation
import NaturalLanguage
import TabularData

private enum TrainingError: Error, CustomStringConvertible {
    case missingArgument(String)
    case unsupportedPredictionLabel(String)
    case missingPrediction

    var description: String {
        switch self {
        case let .missingArgument(name): "Missing required argument \(name)."
        case let .unsupportedPredictionLabel(label): "Model returned unsupported label: \(label)."
        case .missingPrediction: "Model returned no prediction hypotheses."
        }
    }
}

private struct Arguments {
    let sourceURL: URL
    let manifestURL: URL
    let outputURL: URL

    init(values: [String]) throws {
        func value(after flag: String) throws -> String {
            guard let index = values.firstIndex(of: flag), values.indices.contains(index + 1) else {
                throw TrainingError.missingArgument(flag)
            }
            return values[index + 1]
        }

        sourceURL = URL(fileURLWithPath: try value(after: "--source"))
        manifestURL = URL(fileURLWithPath: try value(after: "--manifest"))
        outputURL = URL(fileURLWithPath: try value(after: "--output"), isDirectory: true)
    }
}

private let splitSeed: UInt64 = 20_260_917
private let modelIdentifier = "SpamClassifierMaxEnt"
private let modelVersion = "1.0.0"

private func dataFrame(_ samples: [PreparedSample]) -> DataFrame {
    var frame = DataFrame()
    frame.append(column: Column(name: "text", contents: samples.map(\.text)))
    frame.append(column: Column(name: "label", contents: samples.map { $0.label.rawValue }))
    return frame
}

private func predictions(
    model: MLTextClassifier,
    samples: [PreparedSample]
) throws -> [LabeledPrediction] {
    try samples.map { sample in
        let hypotheses = try model.predictionWithConfidence(from: sample.text)
        guard let winner = hypotheses.max(by: { $0.value < $1.value }) else {
            throw TrainingError.missingPrediction
        }
        guard let label = DatasetLabel(rawValue: winner.key) else {
            throw TrainingError.unsupportedPredictionLabel(winner.key)
        }
        return LabeledPrediction(
            expected: sample.label,
            predicted: label,
            confidence: winner.value,
            sampleID: sample.sampleID
        )
    }
}

private func splitSummary(_ name: String, _ samples: [PreparedSample]) -> SplitSummary {
    SplitSummary(
        name: name,
        total: samples.count,
        suspicious: samples.count { $0.label == .suspicious },
        legitimate: samples.count { $0.label == .legitimate },
        groups: Set(samples.map(\.groupID)).count
    )
}

private func errorCategory(sample: PreparedSample, prediction: LabeledPrediction) -> String {
    let tokens = sample.text.split { $0.isWhitespace }
    if tokens.count < 6 { return "Limited message context" }
    if sample.text.contains("<URL>") || sample.text.contains("<PHONE>") || sample.text.contains("<AMOUNT>") {
        return "Identifier or transaction pattern"
    }
    if prediction.expected == .legitimate {
        return "Ordinary message with spam-like wording"
    }
    return "Suspicious pattern underweighted"
}

private func labelAndConfidence(_ hypotheses: [String: Double]) throws -> (DatasetLabel, Double) {
    guard let winner = hypotheses.max(by: { $0.value < $1.value }) else {
        throw TrainingError.missingPrediction
    }
    guard let label = DatasetLabel(rawValue: winner.key) else {
        throw TrainingError.unsupportedPredictionLabel(winner.key)
    }
    return (label, winner.value)
}

private func median(_ values: [Double]) -> Double {
    let sorted = values.sorted()
    guard !sorted.isEmpty else { return 0 }
    if sorted.count.isMultiple(of: 2) {
        return (sorted[sorted.count / 2 - 1] + sorted[sorted.count / 2]) / 2
    }
    return sorted[sorted.count / 2]
}

private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(value).write(to: url, options: .atomic)
}

private func run() throws {
    let arguments = try Arguments(values: Array(CommandLine.arguments.dropFirst()))
    let manifest = try DatasetPreparer.loadManifest(at: arguments.manifestURL)
    let sourceData = try DatasetPreparer.validateSource(at: arguments.sourceURL, manifest: manifest)
    let samples = try DatasetPreparer.prepare(data: sourceData, source: manifest.datasetID)
    let split = try GroupedSplitter.split(samples, seed: splitSeed)
    let duplicates = DatasetPreparer.duplicateSummary(samples)

    try FileManager.default.createDirectory(at: arguments.outputURL, withIntermediateDirectories: true)
    try writeJSON(split, to: arguments.outputURL.appending(path: "split-summary-local.json"))

    let trainingFrame = dataFrame(split.training)
    let validationFrame = dataFrame(split.validation)
    let parameters = MLTextClassifier.ModelParameters(
        validation: .dataFrame(validationFrame, textColumn: "text", labelColumn: "label"),
        algorithm: .maxEnt(revision: 1),
        language: .english
    )

    let trainingStart = ContinuousClock.now
    let classifier = try MLTextClassifier(
        trainingData: trainingFrame,
        textColumn: "text",
        labelColumn: "label",
        parameters: parameters
    )
    let trainingDuration = ContinuousClock.now - trainingStart

    let modelURL = arguments.outputURL.appending(path: "SpamClassifierMaxEntV1.mlmodel")
    let metadata = MLModelMetadata(
        author: "Challenge6 Academy Demo",
        shortDescription: "Learning-first on-device English SMS spam classifier. Confidence is not certainty and output is not safety advice.",
        license: "Training data: UCI SMS Spam Collection, CC BY 4.0",
        version: modelVersion,
        additional: [
            "dataset_source": manifest.canonicalPage,
            "dataset_sha256": manifest.dataFileSHA256,
            "intended_use": "Educational on-device spam analysis demonstration",
            "known_limitations": "Older English SMS corpus; not all modern scams; not production safety advice",
            "split_seed": String(splitSeed),
            "algorithm": "MLTextClassifier maxEnt revision 1"
        ]
    )
    try classifier.write(to: modelURL, metadata: metadata)

    let majority = MajorityClassBaseline(trainingSamples: split.training)
    let naiveBayes = TransparentNaiveBayesBaseline(trainingSamples: split.training)
    let trainingPredictions = try predictions(model: classifier, samples: split.training)
    let validationPredictions = try predictions(model: classifier, samples: split.validation)
    let holdoutPredictions = try predictions(model: classifier, samples: split.holdout)

    let compiledURL = try MLModel.compileModel(at: modelURL)
    defer { try? FileManager.default.removeItem(at: compiledURL) }
    let runtimeModel = try NLModel(mlModel: MLModel(contentsOf: compiledURL))

    let demoMessages = [
        ("Suspicious", "URGENT! Your mobile number has won a $5,000 cash prize. Click now to verify and claim your reward."),
        ("Legitimate", "Hi Maya, our project meeting is at 10:30 tomorrow in the library. Please bring the latest notes."),
        ("Ambiguous", "Urgent: verify the delivery link at portal.example/check.")
    ]
    let demoPredictions = try demoMessages.map { name, text in
        let result = try labelAndConfidence(runtimeModel.predictedLabelHypotheses(for: text, maximumCount: 2))
        return DemoPrediction(name: name, text: text, predicted: result.0, confidence: result.1)
    }

    let latencyInput = demoMessages[0].1
    _ = runtimeModel.predictedLabelHypotheses(for: latencyInput, maximumCount: 2)
    let latencyMeasurements = (0..<100).map { _ -> Double in
        let start = ContinuousClock.now
        _ = runtimeModel.predictedLabelHypotheses(for: latencyInput, maximumCount: 2)
        let duration = ContinuousClock.now - start
        return Double(duration.components.attoseconds) / 1_000_000_000_000_000
    }

    let fileAttributes = try FileManager.default.attributesOfItem(atPath: modelURL.path)
    let modelSize = (fileAttributes[.size] as? NSNumber)?.intValue ?? 0
    let holdoutByID = Dictionary(uniqueKeysWithValues: split.holdout.map { ($0.sampleID, $0) })
    let incorrect = holdoutPredictions
        .filter { $0.expected != $0.predicted }
        .sorted { ($0.sampleID ?? "") < ($1.sampleID ?? "") }
    let errorReviews = incorrect.prefix(10).compactMap { prediction -> ErrorReview? in
        guard let sampleID = prediction.sampleID,
              let confidence = prediction.confidence,
              let sample = holdoutByID[sampleID] else { return nil }
        return ErrorReview(
            sampleID: sampleID,
            expected: prediction.expected,
            predicted: prediction.predicted,
            confidence: confidence,
            category: errorCategory(sample: sample, prediction: prediction)
        )
    }

    let localErrorDetails = incorrect.compactMap { prediction -> [String: String]? in
        guard let sampleID = prediction.sampleID, let sample = holdoutByID[sampleID] else { return nil }
        return [
            "sample_id": sampleID,
            "text": sample.text,
            "expected": prediction.expected.rawValue,
            "predicted": prediction.predicted.rawValue,
            "confidence": String(prediction.confidence ?? 0)
        ]
    }
    try writeJSON(localErrorDetails, to: arguments.outputURL.appending(path: "incorrect-predictions-local.json"))

    let durationSeconds = Double(trainingDuration.components.seconds)
        + Double(trainingDuration.components.attoseconds) / 1_000_000_000_000_000_000
    let record = ExperimentRecord(
        experimentID: "maxent-v1",
        createdAt: ISO8601DateFormatter().string(from: Date()),
        datasetID: manifest.datasetID,
        sourceSHA256: manifest.dataFileSHA256,
        splitSeed: splitSeed,
        modelIdentifier: modelIdentifier,
        modelVersion: modelVersion,
        algorithm: "Core ML Maximum Entropy Text Classifier (revision 1)",
        language: "English",
        trainingDurationSeconds: durationSeconds,
        modelSizeBytes: modelSize,
        latencyMilliseconds: median(latencyMeasurements),
        totalSamples: samples.count,
        duplicateSummary: duplicates,
        splitSummaries: [
            splitSummary("training", split.training),
            splitSummary("validation", split.validation),
            splitSummary("holdout", split.holdout)
        ],
        evaluations: [
            EvaluationRecord(name: "Majority holdout", metrics: ClassificationMetrics(predictions: majority.predictions(for: split.holdout))),
            EvaluationRecord(name: "Naive Bayes validation", metrics: ClassificationMetrics(predictions: naiveBayes.predictions(for: split.validation))),
            EvaluationRecord(name: "Naive Bayes holdout", metrics: ClassificationMetrics(predictions: naiveBayes.predictions(for: split.holdout))),
            EvaluationRecord(name: "MaxEnt training", metrics: ClassificationMetrics(predictions: trainingPredictions)),
            EvaluationRecord(name: "MaxEnt validation", metrics: ClassificationMetrics(predictions: validationPredictions)),
            EvaluationRecord(name: "MaxEnt holdout", metrics: ClassificationMetrics(predictions: holdoutPredictions))
        ],
        errorReviews: errorReviews,
        demoPredictions: demoPredictions
    )

    try writeJSON(record, to: arguments.outputURL.appending(path: "maxent-v1.json"))
    try ReportWriter.markdown(record: record)
        .write(to: arguments.outputURL.appending(path: "maxent-v1-evaluation.md"), atomically: true, encoding: .utf8)

    print("Prepared \(samples.count) samples")
    print("Training / validation / holdout: \(split.training.count) / \(split.validation.count) / \(split.holdout.count)")
    print("Model written to \(modelURL.path)")
    print("Experiment record written to \(arguments.outputURL.path)")
}

do {
    try run()
} catch {
    FileHandle.standardError.write(Data("Training failed: \(error)\n".utf8))
    exit(EXIT_FAILURE)
}
