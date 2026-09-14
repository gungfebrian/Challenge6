#!/bin/zsh

set -euo pipefail

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_directory="$(cd "$script_directory/.." && pwd)"
test_binary="${TMPDIR:-/tmp}/challenge6-classifier-tests"

swiftc \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisRequest.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Models/AnalysisResult.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MLService.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift" \
    "$repository_directory/Challenge6/Features/Analysis/Services/MultinomialNaiveBayesService.swift" \
    "$repository_directory/Tests/Challenge6CoreTests/MultinomialNaiveBayesClassifierTests.swift" \
    -o "$test_binary"

"$test_binary"
