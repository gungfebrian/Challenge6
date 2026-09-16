#!/bin/zsh

set -euo pipefail

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_directory="$(cd "$script_directory/.." && pwd)"
test_binary="${TMPDIR:-/tmp}/challenge6-core-tests"

swiftc \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisRequest.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisResult.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MLService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TextTokenizer.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TokenBag.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/PredictionScores.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/TrainingDataValidator.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/SpamTrainingDataset.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TestSupport.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TextTokenizerTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TokenBagTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/PredictionScoresTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TrainingDataValidatorTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/AnalysisRequestTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/MultinomialNaiveBayesClassifierTests.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/TestMain.swift" \
    -o "$test_binary"

"$test_binary"
