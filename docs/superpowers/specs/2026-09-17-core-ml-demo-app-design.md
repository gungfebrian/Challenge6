# Core ML Academy Demo App Design

## Product intent

Challenge6 will become a polished native iOS demonstration of on-device text classification while staying explicitly educational. The product promise is: “A learning-first, privacy-conscious, on-device spam analysis demo.” It will never describe a prediction as certainty, safety advice, or a substitute for independent verification and official reporting channels.

The primary presentation flow is short and inspectable: analyze one of three English examples, compare confidence and guidance, review local history, inspect privacy and model details, then return to an intentionally ambiguous example to discuss limitations.

## Architecture

The existing feature-first MVVM boundaries remain in place:

- `Challenge6App` is the composition root and creates the production Core ML service and SwiftData container.
- `AnalysisViewModel` owns renderable analysis state, cancellation, stale-result protection, and the request to persist a successful current result.
- `MLService` remains independent of SwiftUI and Core ML implementation details.
- `CoreMLTextClassifierService` is an actor that owns `NLModel`, maps its hypotheses to domain labels, validates scores, and returns model identity with each result.
- `MultinomialNaiveBayesClassifier` remains a transparent learning baseline and continues to support previews and focused tests.
- SwiftData stores only completed analysis records. A focused history store owns insertion, deterministic 50-record retention, deletion, and clear-all behavior; classifier types never depend on SwiftData.
- `AppPreferences` centralizes `UserDefaults` keys. Views use `@AppStorage` with those keys for history and haptic settings.

The root UI is a native `TabView` with an independent `NavigationStack` in each of Check, History, and Settings. Standard `Form`, `List`, `ContentUnavailableView`, `NavigationLink`, `Gauge`, buttons, alerts, and SF Symbols provide platform behavior without third-party UI code.

## Model and data pipeline

The production model is a versioned Create ML text classifier trained with `MLTextClassifier` using `.maxEnt` and English. Runtime prediction uses `NaturalLanguage.NLModel.predictedLabelHypotheses(for:maximumCount:)` so Create ML and the app share the intended text-model runtime.

The official UCI SMS Spam Collection is acquired only into a gitignored local directory. The preparation tool validates the pinned SHA-256 checksum, rejects malformed rows, maps `spam` to `suspicious` and `ham` to `legitimate`, and replaces obvious identifiers with stable placeholders. Stable SHA-256 digests identify samples and normalized duplicate groups; no Swift `hashValue` is used.

The tool makes deterministic, label-stratified 70/15/15 group splits with a recorded seed. Exact normalized duplicates stay in one split, and split validation rejects sample or group overlap. It evaluates the majority baseline, the existing inspectable Multinomial Naive Bayes baseline, and the frozen MaxEnt candidate on the same holdout. It emits a structured JSON experiment record, a Markdown report with real metrics and at least ten reviewed holdout errors when available, and `SpamClassifierMaxEntV1.mlmodel` with author, version, source, intended-use, and limitations metadata.

Only the model, scripts, provenance, and reports are committed. Raw and derived message rows remain ignored because the public corpus includes live-looking identifiers and conversational text that should not become an application repository dependency.

## Runtime behavior and errors

`AnalysisResult` includes label, finite clamped confidence, model identifier, and model version. The Core ML service has typed failures for unavailable model, missing prediction, unsupported label, invalid confidence, and underlying prediction failure. UI copy maps these failures into useful recovery guidance without exposing framework errors or message text.

The analysis state machine supports idle, loading, success, empty input, model unavailable, invalid prediction, service failure, and an independent persistence warning. A second submission while loading is ignored. Cancellation returns to idle. Before displaying or saving a result, the view model verifies that the normalized current text still matches the request. Persistence errors do not remove a valid visible prediction.

## Check experience

The Check tab presents on-device value copy, three labeled example buttons, a visible editor label and placeholder, a 44-point clear control, and one dominant “Analyze Message” action. Examples only populate the editor. During analysis the CTA is disabled and carries a progress state.

A successful result combines a semantic icon and text, confidence gauge, model name/version, a reminder that confidence is not certainty, and label-appropriate next steps. “Check Another Message” resets the flow. Haptics fire only after a current successful result and only when enabled. The editor retains text after recoverable failures and receives focus after empty submission.

## History and settings

`AnalysisRecord` stores a UUID, normalized message text, raw result label, confidence, timestamp, model identifier, and model version locally. Saving defaults on and occurs only for a successful current result. Inserting record 51 removes the oldest record by timestamp then UUID for deterministic retention.

History lists newest first, uses text and icon in addition to color, opens a full detail view, supports swipe deletion plus a visible detail-screen Delete action, and confirms Clear All. Settings uses a native form for history saving, haptics, active model facts, dataset attribution, privacy, destructive history clearing, educational purpose, and limitations. Disabling history affects future results but never deletes existing records.

## Visual and accessibility direction

The app stays deliberately native: semantic system colors, system Dynamic Type styles, SF Symbols, 4/8-point spacing tokens, native control pressed states, and adaptive readable widths. It supports dark mode, small and large iPhones, iPad, landscape, large accessibility sizes, safe areas, the keyboard, and Reduce Motion. Result meaning always includes icon and text. Interactive controls provide at least 44-by-44-point hit areas, concise labels and hints, logical reading order, and announcements for loading, completion, and failure.

## Verification strategy

Pure Swift focused checks cover domain mapping, state transitions, cancellation/staleness, preference defaults, persistence orchestration, deterministic retention decisions, preparation validation, sanitization, grouped splitting, and metrics. A small bundled-model smoke check runs where the model and Apple frameworks are available. The final gate is the focused check script, training-tool tests, a generic iOS Simulator build, simulator launch and screenshots across requested appearances/configurations where tooling permits, source-level accessibility review, git status review, and an ordinary push to `origin/main`.

## Known limitations

The UCI corpus is older, English-focused, and shaped by its collection sources. It does not represent every modern scam, language, region, or conversational context. Benchmark performance on a grouped holdout does not establish production readiness. The model cannot provide reliable per-token explanations, so the interface will not claim that particular words caused a prediction.
