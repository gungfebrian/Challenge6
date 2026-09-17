import Foundation

enum DatasetSplitError: Error, Equatable {
    case conflictingLabels(groupID: String)
    case duplicateSampleID(String)
    case sampleCoverageMismatch
    case groupOverlap(String)
}

struct DatasetSplitResult: Codable, Equatable, Sendable {
    let seed: UInt64
    let training: [PreparedSample]
    let validation: [PreparedSample]
    let holdout: [PreparedSample]

    func validate(originalSamples: [PreparedSample]) throws {
        let originalIDs = originalSamples.map(\.sampleID)
        guard Set(originalIDs).count == originalIDs.count else {
            let duplicate = Dictionary(grouping: originalIDs, by: { $0 })
                .first(where: { $0.value.count > 1 })?.key ?? "unknown"
            throw DatasetSplitError.duplicateSampleID(duplicate)
        }

        let combined = training + validation + holdout
        guard combined.count == originalSamples.count,
              Set(combined.map(\.sampleID)) == Set(originalIDs) else {
            throw DatasetSplitError.sampleCoverageMismatch
        }

        var splitByGroup: [String: Int] = [:]
        for (splitIndex, samples) in [training, validation, holdout].enumerated() {
            for groupID in Set(samples.map(\.groupID)) {
                if let existing = splitByGroup[groupID], existing != splitIndex {
                    throw DatasetSplitError.groupOverlap(groupID)
                }
                splitByGroup[groupID] = splitIndex
            }
        }
    }
}

enum GroupedSplitter {
    private struct SampleGroup {
        let id: String
        let label: DatasetLabel
        let samples: [PreparedSample]
    }

    static func split(
        _ samples: [PreparedSample],
        seed: UInt64,
        trainingFraction: Double = 0.70,
        validationFraction: Double = 0.15
    ) throws -> DatasetSplitResult {
        let groups = try makeGroups(samples)
        var partitions: [[PreparedSample]] = [[], [], []]

        for label in DatasetLabel.allCases {
            var labelGroups = groups
                .filter { $0.label == label }
                .sorted { $0.id < $1.id }
            let labelSeed = seed ^ (label == .suspicious ? 0x535553504943494F : 0x4C45474954494D41)
            var generator = SeededGenerator(seed: labelSeed)
            labelGroups.shuffle(using: &generator)

            let sampleCount = labelGroups.reduce(0) { $0 + $1.samples.count }
            let trainingTarget = Int((Double(sampleCount) * trainingFraction).rounded())
            let validationTarget = Int((Double(sampleCount) * validationFraction).rounded())
            let targets = [trainingTarget, validationTarget, sampleCount - trainingTarget - validationTarget]
            var counts = [0, 0, 0]

            for group in labelGroups {
                let selectedIndex = (0..<3).max { lhs, rhs in
                    let lhsDeficit = targets[lhs] - counts[lhs]
                    let rhsDeficit = targets[rhs] - counts[rhs]
                    if lhsDeficit == rhsDeficit {
                        return lhs > rhs
                    }
                    return lhsDeficit < rhsDeficit
                } ?? 0

                partitions[selectedIndex].append(contentsOf: group.samples)
                counts[selectedIndex] += group.samples.count
            }
        }

        let result = DatasetSplitResult(
            seed: seed,
            training: partitions[0].sorted { $0.sampleID < $1.sampleID },
            validation: partitions[1].sorted { $0.sampleID < $1.sampleID },
            holdout: partitions[2].sorted { $0.sampleID < $1.sampleID }
        )
        try result.validate(originalSamples: samples)
        return result
    }

    private static func makeGroups(_ samples: [PreparedSample]) throws -> [SampleGroup] {
        try Dictionary(grouping: samples, by: \.groupID).map { groupID, members in
            let labels = Set(members.map(\.label))
            guard labels.count == 1, let label = labels.first else {
                throw DatasetSplitError.conflictingLabels(groupID: groupID)
            }
            return SampleGroup(id: groupID, label: label, samples: members)
        }
    }
}
