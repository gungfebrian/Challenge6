# Academy Demo and Engineering Guide

## Positioning

Use this sentence to open the presentation:

> Challenge6 is a learning-first, privacy-conscious, on-device spam analysis demo.

Do not describe it as a production security product, guaranteed scam detector, professional safety advice, or replacement for user judgment and official reporting channels.

## Presentation script

1. Open **Check** and explain that input stays on the device.
2. Select **Suspicious**. Point out that selecting an example fills the editor but does not analyze automatically.
3. Tap **Analyze Message**. Explain the actual result: **Likely Spam**, about **95%** model confidence. Confidence is a score, not certainty; it does not identify causal words.
4. Tap **Check Another Message**, select **Legitimate**, and analyze it. The frozen model returns **Likely Not Spam** at about **99.99%**.
5. Open **History**. Show both locally persisted records and open one detail screen to show full text, date, and model version.
6. Open **Settings**. Explain the history and haptic controls, local-only storage, no CloudKit, and no analytics. Open **Model & Dataset Information**.
7. Return to **Check**, select **Ambiguous**, and analyze it. The frozen model returns **Likely Not Spam** at about **50%**, a useful demonstration that missing context can leave the model uncertain.
8. Close by explaining that the corpus is older and English-focused, the Naive Bayes baseline actually measured better on this holdout, and future work should improve representative data and evaluation rather than overstate the current result.

Demo predictions are recorded by the training pipeline from the real exported artifact. Never add these examples to training data just to change their outcomes.

## Runtime architecture

```text
SwiftUI Check view
  -> AnalysisViewModel
     -> MLService boundary
        -> CoreMLTextClassifierService actor
           -> bundled .mlmodelc
           -> NLModel label hypotheses
     -> current-result and cancellation checks
     -> AnalysisHistorySaving boundary
        -> SwiftDataHistoryStore
           -> local store, CloudKit disabled
```

The service asks `NLModel` for label hypotheses, explicitly maps only `suspicious` and `legitimate`, clamps finite confidence into `0...1`, and returns model identity with the result. Missing models, missing predictions, invalid scores, and unknown labels become typed errors. There is no silent Naive Bayes fallback.

The view model normalizes input before analysis. A request cannot submit twice while loading. Cancellation returns to idle, and a result is discarded if the editor text changed during inference. Only a successful result for the current normalized message can be saved.

## Why both classifiers exist

The project began with a hand-written Multinomial Naive Bayes classifier because its mechanics can be followed line by line:

- tokenization and bag-of-words counts;
- class counts and prior probabilities;
- Laplace smoothing for unseen tokens;
- log-probability accumulation; and
- deterministic result comparison.

That implementation remains valuable teaching material and a strong transparent baseline. The app uses Core ML MaxEnt by default to demonstrate Apple's native Create ML training, Core ML artifact, and Natural Language inference path with consistent tokenization. Model choice is reported honestly: on the frozen holdout, Naive Bayes scored higher than MaxEnt.

## History and settings privacy

SwiftData stores a stable UUID, normalized message text, result label, confidence, timestamp, model identifier, and model version. Records are newest first. After a successful insert, deterministic retention removes the oldest timestamp first, using UUID as a tie-break, until no more than 50 remain.

History saving defaults to enabled. Turning it off affects future successful analyses and does not delete existing records. Clear All requires destructive confirmation. A persistence failure leaves the visible classifier result intact and shows a separate warning.

Haptic feedback defaults to enabled and gates success, warning, and error feedback. Preference keys are centralized in `AppPreferences` and backed by `UserDefaults`/`@AppStorage`.

The app configures no CloudKit database, network classifier, telemetry, analytics, export, or sharing feature. Opening the optional external UCI source link is the only user-initiated network destination; core app operation does not depend on it.

## Dataset preparation and leakage prevention

The macOS pipeline:

1. requires the expected UCI source file and validates the pinned SHA-256;
2. parses every tab-separated row and rejects malformed data;
3. maps `spam` to `suspicious` and `ham` to `legitimate`;
4. replaces obvious phone numbers, emails, URLs, amounts, and account/credential values with stable placeholders;
5. assigns SHA-256 sample and normalized-group identifiers;
6. keeps exact and normalized duplicate groups in one split;
7. creates deterministic, stratified training, validation, and final holdout splits using seed `20260917`;
8. evaluates majority and hand-written Naive Bayes baselines on the same frozen split;
9. trains `MLTextClassifier` with maximum entropy revision 1 and English language configuration; and
10. exports the model, structured experiment record, readable report, private local error details, and demo predictions.

Prepared rows remain gitignored because public licensing alone does not weaken the repository's stricter message privacy contract.

## Model artifact versioning

The artifact filename, `ModelMetadata`, experiment JSON, evaluation report, and Core ML metadata must identify the same release. A replacement requires a new reviewed experiment and model version. Never overwrite metrics by hand or use holdout outcomes for tuning.

Current release:

- identifier: `SpamClassifierMaxEnt`
- version: `1.0.0`
- artifact: `Challenge6/Resources/Models/SpamClassifierMaxEntV1.mlmodel`
- size: 143,456 bytes
- SHA-256: `e606d7910ffa8ff4decd523407a6c13e8f10f8bda0c2ea35ba97c00a73685b67`

## Accessibility and adaptive layout checklist

- Native text styles support Dynamic Type; no fixed font sizes are used.
- Controls use native semantics and at least 44-point targets.
- Icons accompany result text, so meaning is not conveyed by color alone.
- Loading, success, failure, and history-save warnings announce through accessibility notifications.
- The result title summarizes label, confidence, and recommended action; the gauge has an explicit accessibility label and value.
- Quick examples announce that they fill the editor without analyzing.
- Destructive actions have destructive roles and confirmation.
- Each tab owns its navigation stack; forms and lists scroll around compact screens, landscape, keyboard, tab bar, and safe areas.
- Content width is capped on iPad while remaining fluid on iPhone.
- The app adds no decorative motion; standard platform transitions respect Reduce Motion.

## Troubleshooting

### The model is unavailable

Confirm `Challenge6/Resources/Models/SpamClassifierMaxEntV1.mlmodel` exists and that the build log compiles it to `SpamClassifierMaxEntV1.mlmodelc`. The UI must show a recoverable error; do not inject the Naive Bayes service into production composition as a fallback.

### Training cannot find the dataset

Follow `docs/data/uci-sms-spam-collection.md` and place the official extracted source in the documented `.local-data` path. Verify both archive and extracted checksums. Do not commit the downloaded corpus.

### The source checksum changed

Stop. Verify the download came from the canonical UCI record and investigate the upstream change. Update provenance only after reviewing content and license; do not bypass checksum validation for convenience.

### History does not appear

Check **Settings → Save Analysis History**. Only successful, current, non-cancelled analyses save. If SwiftData reports a failure, the current result remains visible with a history warning.

### Results differ after retraining

Confirm dataset checksum, split seed, Create ML/Xcode version, preprocessing, and model metadata. The deterministic data split does not promise bit-for-bit deterministic optimizer output across framework or OS versions, so preserve and compare each experiment artifact and its actual predictions.

### Simulator build uses the wrong developer directory

Prefix commands with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. Do not change the machine's global `xcode-select` setting for this project.
