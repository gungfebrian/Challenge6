# Challenge6 — On-Device Spam Check

Challenge6 is a learning-first, privacy-conscious, on-device spam analysis demo built with SwiftUI, SwiftData, Create ML, and Natural Language. It is an Academy presentation project—not a production security system, guaranteed scam detector, or source of professional safety advice.

## Run the app

Requirements: Xcode 26.6 or later and an iOS 26.5 simulator or device.

1. Clone the repository.
2. Open `Challenge6.xcodeproj`.
3. Select the `Challenge6` scheme and an iOS destination.
4. Build and run with **Command-R**.

The bundled default is **Core ML MaxEnt 1.0.0**. Analysis uses `NaturalLanguage.NLModel` entirely on device; the app does not upload messages, use analytics, or sync history through CloudKit.

## Product walkthrough

- **Check:** choose one of three English examples or enter a message, then review the prediction, confidence score, model version, and recommended next action.
- **History:** inspect up to 50 successful analyses saved locally, open full details, delete one, or clear all.
- **Settings:** control future history saving and haptics, clear saved messages, and review model, dataset, privacy, and limitation information.

Confidence is a model score, not certainty. Independently verify suspicious and unexpected messages.

## Models and measured evidence

The production app uses a Create ML maximum entropy text classifier trained with `MLTextClassifier` and `.maxEnt`, then loaded through `NLModel` so training and runtime tokenization stay aligned.

The hand-written `MultinomialNaiveBayesClassifier` remains as an inspectable learning baseline. It makes tokenization, counts, priors, Laplace smoothing, and log-probability scoring concrete and testable. It is deliberately **not** a runtime fallback: if Core ML cannot load or returns an unsupported result, the UI shows a typed recoverable error.

Frozen holdout results on the same grouped split:

| Model | Accuracy | Suspicious precision | Suspicious recall | Suspicious F1 |
|---|---:|---:|---:|---:|
| Majority class | 86.71% | 0.00% | 0.00% | 0.00% |
| Multinomial Naive Bayes | 99.04% | 99.05% | 93.69% | 96.30% |
| Core ML MaxEnt 1.0.0 | 97.72% | 94.23% | 88.29% | 91.16% |

MaxEnt was selected for the app to demonstrate the native Create ML/Core ML/Natural Language workflow—not because it beat the learning baseline. Full confusion matrices, validation results, latency, and error review are in [the evaluation report](docs/modeling/maxent-v1-evaluation.md).

## Dataset and privacy

Training uses the public **UCI SMS Spam Collection** by Almeida and Hidalgo (2011), licensed under **Creative Commons Attribution 4.0**. The source contains 5,574 labeled English SMS messages. Original `spam` and `ham` labels map to `suspicious` and `legitimate`.

Raw and prepared message rows remain in gitignored local storage. The reproducible pipeline verifies the pinned checksum, rejects malformed rows, sanitizes obvious identifiers, assigns SHA-256 identifiers, groups exact and normalized duplicates, and creates fixed-seed stratified train/validation/holdout splits. Only scripts, provenance, aggregate reports, and the final model are committed.

- [Dataset provenance and license](docs/data/uci-sms-spam-collection.md)
- [Repository message-data contract](docs/data/message-dataset-contract.md)
- [Structured experiment record](docs/modeling/experiments/maxent-v1.json)

The corpus is older, English-focused, and does not represent every modern scam, language, region, or conversational context. High benchmark accuracy does not establish production readiness.

## Verification

Focused core, mapping, state, preference, retention, and in-memory SwiftData checks:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/run-classifier-checks.sh
```

Dataset preparation, deterministic splitting, leakage, and metric checks:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/run-training-checks.sh
```

Generic Simulator build without changing global `xcode-select`:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild \
    -project Challenge6.xcodeproj \
    -scheme Challenge6 \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath /tmp/Challenge6DerivedData \
    build
```

## Re-train on macOS

Acquire the official archive using [the pinned provenance instructions](docs/data/uci-sms-spam-collection.md), then run:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/train-spam-classifier.sh
```

The command validates local input and writes ignored artifacts under `Scripts/Training/Output/`. Review the generated experiment JSON, Markdown report, error details, demo predictions, and model before intentionally replacing the committed artifact. Never tune against the final holdout results.

To release a replacement:

1. Choose a new immutable experiment ID and model semantic version.
2. Freeze preparation, split, and model parameters before final holdout evaluation.
3. Compare the majority, Naive Bayes, and MaxEnt results on the same split.
4. Copy the reviewed `.mlmodel`, experiment JSON, and report into their versioned repository locations.
5. Update `ModelMetadata.coreMLMaxEnt` to the matching identifier/version.
6. Run the full verification and simulator demo flows.

The current `SpamClassifierMaxEntV1.mlmodel` is 143,456 bytes with SHA-256 `e606d7910ffa8ff4decd523407a6c13e8f10f8bda0c2ea35ba97c00a73685b67`.

## Architecture

```text
Challenge6/
├── App/                  # Production composition and three-tab shell
├── DesignSystem/         # Spacing and layout tokens
├── Features/
│   ├── Analysis/         # Domain input/results, services, view model, Check UI
│   └── History/          # Domain history contract, SwiftData adapter, History UI
├── Resources/Models/     # Versioned Core ML model
└── Settings/             # Centralized preferences and Settings UI
```

`MLService: Sendable` keeps feature state independent of Core ML. `CoreMLTextClassifierService` is an actor that owns the non-Sendable `NLModel`. `AnalysisViewModel` protects against cancellation, duplicate requests, and stale results before saving. SwiftData remains behind a history boundary and uses an explicitly local configuration with CloudKit disabled.

See [the Academy demo and engineering guide](docs/academy-demo-guide.md) for runtime details, presentation steps, known limitations, and troubleshooting. The original [MVVM learning guide](docs/mvvm-learning-guide.md) remains useful background for the project structure.
