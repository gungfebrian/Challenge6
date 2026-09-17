#!/bin/zsh

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
build_directory="$(mktemp -d /tmp/challenge6-training.XXXXXX)"
trap 'rm -rf "$build_directory"' EXIT

output_directory="${1:-$repository_root/Scripts/Training/Output/maxent-v1}"
source_file="$repository_root/.local-data/uci-sms-spam/raw/extracted/SMSSpamCollection"
manifest_file="$repository_root/Data/Manifests/uci-sms-spam-v1.json"

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun swiftc \
  -swift-version 6 \
  "$repository_root"/Scripts/Training/Sources/TrainingCore/*.swift \
  "$repository_root"/Scripts/Training/Sources/TrainSpamClassifier/main.swift \
  -o "$build_directory/train-spam-classifier"

"$build_directory/train-spam-classifier" \
  --source "$source_file" \
  --manifest "$manifest_file" \
  --output "$output_directory"
