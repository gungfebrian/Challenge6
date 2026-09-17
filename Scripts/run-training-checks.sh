#!/bin/zsh

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
build_directory="$(mktemp -d /tmp/challenge6-training-checks.XXXXXX)"
trap 'rm -rf "$build_directory"' EXIT

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun swiftc \
  -swift-version 6 \
  "$repository_root"/Scripts/Training/Sources/TrainingCore/*.swift \
  "$repository_root"/Scripts/TrainingTests/*.swift \
  -o "$build_directory/training-checks"

"$build_directory/training-checks"
