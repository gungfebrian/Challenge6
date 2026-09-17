#!/bin/zsh

set -euo pipefail

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_directory="$(cd "$script_directory/.." && pwd)"
test_binary="${TMPDIR:-/tmp}/challenge6-core-tests"

swiftc \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisRequest.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisResult.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Models/ModelMetadata.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MLService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/CoreMLPredictionMapper.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MLServiceError.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/CoreMLTextClassifierService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TextTokenizer.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TokenBag.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/PredictionScores.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TrainingDataValidator.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/SpamTrainingDataset.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift" \
    "$repository_directory/Challenge6/Features/History/Models/AnalysisHistoryEntry.swift" \
    "$repository_directory/Challenge6/Features/History/Services/AnalysisHistorySaving.swift" \
    "$repository_directory/Challenge6/Features/History/Services/HistoryRetentionPolicy.swift" \
    "$repository_directory/Challenge6/Settings/AppPreferences.swift" \
    "$repository_directory/Challenge6/Features/History/Persistence/AnalysisRecord.swift" \
    "$repository_directory/Challenge6/Features/History/Persistence/SwiftDataHistoryStore.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TestSupport.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TextTokenizerTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TokenBagTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/PredictionScoresTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TrainingDataValidatorTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/AnalysisRequestTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/CoreMLPredictionMapperTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/CoreMLServiceContractTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/MultinomialNaiveBayesClassifierTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/AnalysisViewModelTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/HistoryRetentionPolicyTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/AppPreferencesTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/SwiftDataHistoryStoreTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TestMain.swift" \
    -o "$test_binary"

"$test_binary"
