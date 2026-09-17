# Core ML Academy Demo App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a demo-ready, learning-first iOS spam analysis app whose default classifier is a reproducibly trained Core ML MaxEnt model, with local history, settings, accessibility, and evidence-backed documentation.

**Architecture:** Preserve the existing feature-first MVVM and `MLService` seam. Add a deterministic native Swift training tool, an actor-isolated `NLModel` service, SwiftData-backed history behind a focused store, centralized preferences, and a three-tab SwiftUI shell.

**Tech Stack:** Swift 6.3 toolchain, SwiftUI, Observation, NaturalLanguage, CoreML, CreateML, TabularData, CryptoKit, SwiftData, Foundation; no third-party dependencies.

**Spec:** `docs/superpowers/specs/2026-09-17-core-ml-demo-app-design.md`

## Global Constraints

- Work directly on `main`, preserve unrelated files, stage explicitly, and never force push.
- Keep the personal PNG and DOCX untracked and untouched.
- Target Xcode 26.6 and iOS 26.5 with no third-party dependencies.
- Keep raw/derived UCI message rows out of git; commit only reproducibility assets, model, and reports.
- Keep the existing Multinomial Naive Bayes implementation as the educational baseline.
- Default runtime classification must use Core ML MaxEnt with no silent fallback.
- Every commit must leave the app buildable and focused checks passing where its sources participate.
- UI copy is English-first and explicitly educational, privacy-conscious, and non-guaranteeing.

---

### Task 1: Approved design and execution map

**Files:**
- Create: `docs/superpowers/specs/2026-09-17-core-ml-demo-app-design.md`
- Create: `docs/superpowers/plans/2026-09-17-core-ml-demo-app.md`

**Interfaces:**
- Consumes: the user brief and current repository boundaries.
- Produces: the source of truth for architecture, safety, scope, and commit boundaries.

- [ ] Write the design and implementation plan with no unresolved placeholders.
- [ ] Search both documents for unresolved markers and contradictions against the brief.
- [ ] Confirm `git diff --check` succeeds.
- [ ] Commit as `docs: define the Core ML migration and demo scope`.

### Task 2: Dataset provenance and repository privacy boundary

**Files:**
- Modify: `.gitignore`
- Create: `docs/data/uci-sms-spam-collection.md`
- Create: `Data/Manifests/uci-sms-spam-v1.json`
- Test: `Scripts/TrainingTests/PreparationTests.swift`

**Interfaces:**
- Consumes: UCI dataset URL, DOI, CC BY 4.0 terms, and the existing dataset contract.
- Produces: pinned acquisition/checksum metadata and ignored `.local-data/` paths.

- [ ] Acquire the official zip into `.local-data/uci-sms-spam/raw/` and calculate SHA-256.
- [ ] Record the canonical source, retrieval date, archive checksum, extracted-file checksum, 5,574-row expectation, citation, license, and limitations.
- [ ] Add `.local-data/` and generated training outputs to `.gitignore`.
- [ ] Add a preparation fixture test that fails until source validation rejects absent or mismatched inputs.
- [ ] Implement only manifest parsing/source validation needed for the test.
- [ ] Run training checks and `git diff --check`.
- [ ] Commit as `data: document the licensed SMS corpus provenance`.

### Task 3: Safe deterministic preparation

**Files:**
- Create: `Scripts/Training/Sources/TrainingCore/DatasetModels.swift`
- Create: `Scripts/Training/Sources/TrainingCore/DatasetPreparer.swift`
- Create: `Scripts/Training/Sources/TrainingCore/StableDigest.swift`
- Create: `Scripts/Training/Sources/TrainingCore/TextSanitizer.swift`
- Create: `Scripts/TrainingTests/PreparationTests.swift`
- Create: `Scripts/run-training-checks.sh`

**Interfaces:**
- Consumes: tab-delimited `ham`/`spam` rows.
- Produces: `PreparedSample(sampleID:text:label:groupID:source:reviewStatus:)`, stable digests, sanitized text, and typed malformed-row failures.

- [ ] Write failing fixture tests for all valid rows, malformed rows, label normalization, phone/email/URL/amount/account sanitization, and stable IDs.
- [ ] Run the new checks and confirm each missing behavior fails.
- [ ] Implement parsing, sanitization, and SHA-256 identifiers with Foundation and CryptoKit.
- [ ] Run the checks and confirm every preparation test passes.
- [ ] Commit as `tooling: validate and sanitize spam training data`.

### Task 4: Group-aware deterministic splitting and metrics

**Files:**
- Create: `Scripts/Training/Sources/TrainingCore/SeededGenerator.swift`
- Create: `Scripts/Training/Sources/TrainingCore/GroupedSplitter.swift`
- Create: `Scripts/Training/Sources/TrainingCore/ClassificationMetrics.swift`
- Create: `Scripts/TrainingTests/SplittingAndMetricsTests.swift`
- Modify: `Scripts/run-training-checks.sh`

**Interfaces:**
- Consumes: prepared samples and fixed seed `20260917`.
- Produces: train/validation/holdout splits and literal confusion/accuracy/precision/recall/F1 metrics.

- [ ] Write failing tests for deterministic output, approximate per-label stratification, duplicate-group unity, no sample/group overlap, and hand-derived metrics.
- [ ] Run tests and verify expected failures.
- [ ] Implement seeded group assignment and metric derivation.
- [ ] Run both training and existing classifier checks.
- [ ] Commit as `tooling: add deterministic grouped dataset splitting`.

### Task 5: Native Create ML training and reports

**Files:**
- Create: `Scripts/Training/Sources/TrainSpamClassifier/main.swift`
- Create: `Scripts/Training/Sources/TrainingCore/Evaluation.swift`
- Create: `Scripts/Training/Sources/TrainingCore/ReportWriter.swift`
- Create: `Scripts/train-spam-classifier.sh`
- Modify: `Scripts/run-training-checks.sh`

**Interfaces:**
- Consumes: validated official corpus, grouped split, and the unchanged training pipeline.
- Produces: majority/Naive Bayes/MaxEnt predictions, metadata, `.mlmodel`, JSON record, and Markdown report.

- [ ] Add failing tests proving evaluation metrics are computed from predictions and report records preserve split/model metadata.
- [ ] Implement a reusable baseline evaluator compatible with the existing Naive Bayes math.
- [ ] Implement Create ML `.maxEnt`, English language, explicit validation data, model metadata, holdout inference, latency sampling, size measurement, and error review output.
- [ ] Run preparation checks, then train once with the frozen pipeline.
- [ ] Verify all 5,574 rows are accounted for, no overlaps exist, and reports agree with raw prediction counts.
- [ ] Commit as `tooling: train and evaluate the MaxEnt classifier`.

### Task 6: Versioned Core ML artifact

**Files:**
- Create: `Challenge6/Resources/Models/SpamClassifierMaxEntV1.mlmodel`
- Create: `docs/modeling/experiments/maxent-v1.json`
- Create: `docs/modeling/maxent-v1-evaluation.md`
- Modify: `docs/modeling/baseline-evaluation.md`

**Interfaces:**
- Consumes: the frozen Task 5 outputs.
- Produces: production model version `1.0.0` plus immutable measured evidence.

- [ ] Copy only the final model and reports from ignored output paths.
- [ ] Inspect model metadata and compiled output using Apple tooling.
- [ ] Run the three fixed demo messages through the real model and record their actual predictions in the report.
- [ ] Build the app to prove Xcode compiles and bundles the model.
- [ ] Commit as `model: add the versioned Core ML spam classifier`.

### Task 7: Domain metadata and Core ML mapping

**Files:**
- Modify: `Challenge6/Features/Analysis/Models/AnalysisResult.swift`
- Create: `Challenge6/Features/Analysis/Models/ModelMetadata.swift`
- Create: `Challenge6/Features/Analysis/Services/CoreMLPredictionMapper.swift`
- Create: `Tests/Challenge6CoreTests/CoreMLPredictionMapperTests.swift`
- Modify: `Scripts/run-classifier-checks.sh`
- Modify: existing callers/tests for the expanded result initializer.

**Interfaces:**
- Consumes: `[String: Double]` label hypotheses and `ModelMetadata`.
- Produces: validated `AnalysisResult` or typed mapping errors.

- [ ] Write failing tests for suspicious, legitimate, confidence bounds, unsupported labels, missing output, invalid scores, and metadata propagation.
- [ ] Run focused checks and confirm failures.
- [ ] Implement the pure mapper and update domain results/baseline metadata.
- [ ] Run focused checks and commit as `feat: map Core ML predictions into domain results`.

### Task 8: Actor-isolated production service

**Files:**
- Create: `Challenge6/Features/Analysis/Services/CoreMLTextClassifierService.swift`
- Create: `Challenge6/Features/Analysis/Services/MLServiceError.swift`
- Modify: `Challenge6/App/Challenge6App.swift`
- Create: `Tests/Challenge6CoreTests/CoreMLServiceContractTests.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Consumes: bundled compiled model and `NLModel` hypotheses.
- Produces: the production `MLService` with typed load/prediction failures and cancellation.

- [ ] Write controlled service contract tests for failure mapping and cancellation without relying on model outputs.
- [ ] Implement actor ownership, bundle URL loading, `MLModel`/`NLModel` creation, hypotheses request, and mapper delegation.
- [ ] Inject the service from the app with no Naive Bayes fallback.
- [ ] Add a practical bundled-model smoke check and run focused checks plus an app build.
- [ ] Commit as `feat: integrate on-device Core ML text predictions`.

### Task 9: Analysis orchestration and persistence contract

**Files:**
- Modify: `Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift`
- Create: `Challenge6/Features/History/Models/AnalysisHistoryEntry.swift`
- Create: `Challenge6/Features/History/Services/AnalysisHistorySaving.swift`
- Create: `Challenge6/Features/History/Services/HistoryRetentionPolicy.swift`
- Modify: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`
- Create: `Tests/Challenge6CoreTests/HistoryRetentionPolicyTests.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Consumes: successful current results, normalized request text, timestamp, and history-enabled state.
- Produces: save calls only for current success, deterministic oldest-first retention decisions, and persistence-warning UI state.

- [ ] Write failing tests for typed view-model failures, duplicate submission, current success saving, disabled/failed/cancelled/stale non-saving, and non-destructive persistence warnings.
- [ ] Write failing retention tests for 50/51 records and timestamp/UUID tie-breaking.
- [ ] Implement the narrow persistence protocol, orchestration, and pure retention policy.
- [ ] Run focused checks and commit as `feat: orchestrate successful analysis history saving`.

### Task 10: SwiftData history and preferences

**Files:**
- Create: `Challenge6/Features/History/Models/AnalysisRecord.swift`
- Create: `Challenge6/Features/History/Services/SwiftDataHistoryStore.swift`
- Create: `Challenge6/Settings/AppPreferences.swift`
- Modify: `Challenge6/App/Challenge6App.swift`
- Create: `Tests/Challenge6CoreTests/AppPreferencesTests.swift`
- Create: `Tests/Challenge6CoreTests/HistoryStoreBehaviorTests.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Consumes: domain history entries and preference lookups.
- Produces: local-only SwiftData storage capped at 50 and centralized default-enabled preference keys.

- [ ] Write failing pure tests for preference defaults/persistence and storage behavior through a testable adapter.
- [ ] Implement `@Model`, main-actor store insertion/deletion/clear/retention, and the local `ModelContainer`.
- [ ] Run focused checks and app build.
- [ ] Commit as `feat: persist private analysis history with SwiftData`.

### Task 11: Native three-tab application shell

**Files:**
- Create: `Challenge6/App/AppRootView.swift`
- Create: `Challenge6/Features/History/Views/HistoryView.swift`
- Create: `Challenge6/Features/Settings/Views/SettingsView.swift`
- Modify: `Challenge6/App/Challenge6App.swift`
- Modify: `Challenge6/DesignSystem/Layout/AppSpacing.swift`

**Interfaces:**
- Consumes: production service, history store, model metadata, and SwiftData environment.
- Produces: three tabs with independent navigation stacks and stable SF Symbol identity.

- [ ] Implement Check, History, and Settings tab roots using native tab/navigation APIs.
- [ ] Add only the spacing/icon tokens needed for consistent native layouts.
- [ ] Build for generic iOS Simulator and inspect small-phone/iPad previews.
- [ ] Commit as `feat: add the native three-tab application shell`.

### Task 12: Polished Check tab

**Files:**
- Modify: `Challenge6/Features/Analysis/Views/AnalysisView.swift`
- Modify: `Challenge6/Features/Analysis/Views/AnalysisStatusView.swift`
- Create: `Challenge6/Features/Analysis/Models/DemoMessage.swift`
- Create: `Challenge6/Features/Analysis/Services/HapticFeedback.swift`

**Interfaces:**
- Consumes: the analysis state machine, three fixed examples, and haptic preference.
- Produces: accessible editor/example/result/reset flow with one dominant CTA.

- [ ] Implement on-device positioning, fixed examples, labeled placeholder editor, clear/reset actions, focus on validation, loading CTA, and keyboard dismissal.
- [ ] Present icon-plus-text result, accessible gauge, actual model identity, uncertainty explanation, next actions, retry/reset, and persistence warning.
- [ ] Respect haptic setting and Reduce Motion; keep all targets at least 44 points.
- [ ] Build and run focused checks.
- [ ] Commit as `feat: polish the on-device spam check experience`.

### Task 13: History browsing and deletion

**Files:**
- Modify: `Challenge6/Features/History/Views/HistoryView.swift`
- Create: `Challenge6/Features/History/Views/HistoryRow.swift`
- Create: `Challenge6/Features/History/Views/HistoryDetailView.swift`

**Interfaces:**
- Consumes: newest-first SwiftData query and model context.
- Produces: empty/list/detail flows, swipe and visible deletion, and confirmed clear-all.

- [ ] Implement native empty state, semantic rows, type-safe details, full saved content, educational disclaimer, swipe deletion, detail delete, and destructive confirmation.
- [ ] Verify accessibility labels, traits, timestamp formatting, and empty state after mutation.
- [ ] Build on phone and iPad destinations.
- [ ] Commit as `feat: add private analysis history browsing`.

### Task 14: Settings, model information, and privacy controls

**Files:**
- Modify: `Challenge6/Features/Settings/Views/SettingsView.swift`
- Create: `Challenge6/Features/Settings/Views/ModelInformationView.swift`

**Interfaces:**
- Consumes: centralized preferences, model metadata, and history clearing action.
- Produces: native form settings, attribution, privacy disclosure, limitations, and confirmed clear-history action.

- [ ] Implement Analysis, Feedback, Model, Privacy, and About sections with defaults enabled.
- [ ] Make history clearing explicit and destructive; explain that disabling future saves preserves existing records.
- [ ] Add detailed model/data/source/limitations information and citation link.
- [ ] Build and commit as `feat: add privacy and model settings`.

### Task 15: Adaptive layout and accessibility hardening

**Files:**
- Modify: affected SwiftUI files in `Challenge6/Features/`
- Modify: `Challenge6/DesignSystem/Layout/AppSpacing.swift`

**Interfaces:**
- Consumes: all completed screen flows.
- Produces: usable layouts across appearance, size, orientation, motion, and assistive-technology settings.

- [ ] Audit semantic colors, Dynamic Type, result meaning, reading order, labels/hints, button roles, 44-point targets, safe areas, and gesture alternatives.
- [ ] Smoke-test light/dark, accessibility text size, Reduce Motion, portrait/landscape, small iPhone, large iPhone, and iPad with simulator tooling where available.
- [ ] Fix every observed truncation, overlap, hidden control, or ambiguous announcement.
- [ ] Run focused checks and generic simulator build.
- [ ] Commit as `fix: harden accessibility and adaptive layouts`.

### Task 16: Reviewer documentation and Academy walkthrough

**Files:**
- Modify: `README.md`
- Modify: `docs/ml-workflow.md`
- Modify: `docs/mvvm-learning-guide.md`
- Create: `docs/academy-demo-script.md`
- Create: `docs/modeling/retraining-guide.md`

**Interfaces:**
- Consumes: final measured model/report/build behavior.
- Produces: clone/build/check/retrain/troubleshoot guidance and a factual presentation script.

- [ ] Document the Naive Bayes learning value, MaxEnt runtime choice, provenance/license/limitations, privacy/sanitization/splitting, metrics, versioning, replacement, runtime architecture, settings, history, troubleshooting, and offline operation.
- [ ] Write the requested Check/History/Settings/ambiguous Academy walkthrough using the real three-example outcomes.
- [ ] Verify every documented command and link.
- [ ] Commit as `docs: add the Academy demo and verification guide`.

### Task 17: Final verification and direct push

**Files:**
- Modify only files required by evidence-backed fixes found during verification.

**Interfaces:**
- Consumes: complete repository state.
- Produces: verified `main`, at least 11 meaningful commits, and ordinary `origin/main` push.

- [ ] Run `./Scripts/run-classifier-checks.sh` and `./Scripts/run-training-checks.sh`.
- [ ] Run the exact generic iOS Simulator `xcodebuild` command with `DEVELOPER_DIR` and isolated DerivedData.
- [ ] Boot an available iPhone simulator, install/launch the app, exercise Check/History/Settings, and capture evidence for appearance/layout variants where practical.
- [ ] Inspect the app without network dependence and review VoiceOver labels in source/tooling.
- [ ] Run `git diff --check`, inspect `git status --short --branch`, count implementation commits, and confirm the two personal files remain untouched/untracked.
- [ ] Commit any final evidence-backed fix as a focused commit, rerun the entire verification suite, then `git push origin main` without force.
