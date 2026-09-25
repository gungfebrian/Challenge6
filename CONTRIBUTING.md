# Contributing

Challenge6 is a learning-first iOS demo. Keep changes consistent with its on-device privacy boundary, documented model limitations, and reproducible training workflow.

## Local checks

Use Xcode 26.6 or later. Set `DEVELOPER_DIR` to the Xcode developer directory when the machine's active command-line tools do not point to that Xcode installation.

Run the focused Swift checks when changing classifier, view-model, preference, or history behavior:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/run-classifier-checks.sh
```

Run the data preparation and metric checks when changing training or evaluation code:

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/run-training-checks.sh
```

For SwiftUI changes, build the `Challenge6` scheme for an iOS Simulator and review the affected screen at compact and accessibility text sizes. The README contains the generic simulator build command.

## Data and model changes

- Use public licensed, synthetic, or explicitly consented examples only. Keep raw message corpora and local training output out of git.
- Preserve the grouped split policy. Never use final holdout results to tune the same experiment.
- For a model release, choose a new experiment ID and model version; update the artifact, metadata, structured record, and evaluation report together.
- Review false positives, false negatives, and demo predictions before replacing the bundled model. Do not report training accuracy as evidence of generalization.
- Follow the [ML workflow](docs/ml-workflow.md), [dataset contract](docs/data/message-dataset-contract.md), and [split policy](docs/data/split-and-leakage.md) for details.

## App behavior and privacy

- Keep inference on device and history local. Do not add message uploads, analytics, or cloud sync without revisiting the product's privacy contract and user-facing disclosure.
- Keep the production `MLService` path explicit. A Core ML failure should remain a typed, recoverable error; Naive Bayes is an educational baseline, not a silent fallback.
- Preserve the app's clear safety limits: confidence is not certainty, and the demo is not a production scam detector or professional advice.

When describing a change, state its user-visible effect and the checks performed. For a screen change, include a Simulator screenshot when available.
