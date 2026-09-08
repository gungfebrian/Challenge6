# Learning-First ML Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the ML and Swift architecture boundaries needed for Challenge6 while leaving model training, inference, UI, persistence, and tests as learner-owned exercises.

**Architecture:** Documentation defines the problem and evaluation contract before application code is introduced. The Swift scaffold then adds value types, an asynchronous service protocol, and observable state without implementing a concrete classifier.

**Tech Stack:** Swift 5, SwiftUI, Observation, Xcode 26.6, iOS 26.5

**Spec:** `docs/superpowers/specs/2026-09-08-learning-first-ml-scaffold-design.md`

## Global Constraints

- Do not add a model file, inference implementation, persistence, networking, analytics, or a finished analysis screen.
- Keep Swift comments focused on architectural reasons and learner decisions.
- Use the repository's configured Git author without assistant attribution or contributor trailers.
- End with exactly eight new commits relative to `8ff8392`.

---

### Task 1: ML Workflow Map

**Files:**
- Create: `docs/ml-workflow.md`

**Interfaces:**
- Consumes: the lifecycle and evidence requirements from the design spec
- Produces: the stage-by-stage workflow used by later data and baseline documents

- [ ] **Step 1:** Document the lifecycle from problem framing through improvement, including the question answered, output, and completion evidence for every stage.
- [ ] **Step 2:** Check the document for unsupported claims and incomplete fields.
- [ ] **Step 3:** Commit with `docs: map the industry ML workflow`.

### Task 2: Message Dataset Contract

**Files:**
- Create: `docs/data/message-dataset-contract.md`

**Interfaces:**
- Consumes: the problem and data stages from `docs/ml-workflow.md`
- Produces: exact sample fields, initial labels, annotation rules, exclusions, and privacy constraints

- [ ] **Step 1:** Define one message per row with `sample_id`, `text`, `label`, `group_id`, `source`, and `review_status` fields.
- [ ] **Step 2:** Define `suspicious` and `legitimate` as provisional binary labels and record ambiguity handling.
- [ ] **Step 3:** Commit with `docs: define the message dataset contract`.

### Task 3: Split and Leakage Policy

**Files:**
- Create: `docs/data/split-and-leakage.md`

**Interfaces:**
- Consumes: `group_id` and data provenance fields from the dataset contract
- Produces: a reproducible 70/15/15 split policy and leakage checks

- [ ] **Step 1:** Require grouping and deduplication before a seeded split.
- [ ] **Step 2:** Reserve test data for one final evaluation and define evidence to record.
- [ ] **Step 3:** Commit with `docs: document split and leakage rules`.

### Task 4: Baseline Evaluation Contract

**Files:**
- Create: `docs/modeling/baseline-evaluation.md`

**Interfaces:**
- Consumes: labels and test isolation rules from the data documents
- Produces: baseline order, metrics, comparison table, and error-analysis procedure

- [ ] **Step 1:** Start with a majority-class sanity check before a simple text classifier.
- [ ] **Step 2:** Define precision, recall, F1, confusion matrix, latency, model size, and ten-error review evidence.
- [ ] **Step 3:** Commit with `docs: define baseline evaluation criteria`.

### Task 5: Analysis Domain Types

**Files:**
- Create: `Challenge6/Features/Analysis/Models/AnalysisRequest.swift`
- Create: `Challenge6/Features/Analysis/Models/AnalysisResult.swift`

**Interfaces:**
- Produces: `AnalysisRequest`, `AnalysisResult`, and `RiskLevel` value types

- [ ] **Step 1:** Add immutable `Equatable` and `Sendable` request/result value types with concise `// Why:` boundary comments.
- [ ] **Step 2:** Build with `xcodebuild -project Challenge6.xcodeproj -scheme Challenge6 -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build` and require `BUILD SUCCEEDED`.
- [ ] **Step 3:** Commit with `feat: add analysis domain types`.

### Task 6: ML Service Boundary

**Files:**
- Create: `Challenge6/Features/Analysis/Services/MLService.swift`

**Interfaces:**
- Consumes: `AnalysisRequest` and `AnalysisResult`
- Produces: `MLService.analyze(_:) async throws -> AnalysisResult`

- [ ] **Step 1:** Define only the protocol; do not add Core ML imports or a concrete service.
- [ ] **Step 2:** Build with the existing Xcode scheme and require `BUILD SUCCEEDED`.
- [ ] **Step 3:** Commit with `feat: define the ML service boundary`.

### Task 7: Analysis View-Model States

**Files:**
- Create: `Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift`

**Interfaces:**
- Consumes: any `MLService`
- Produces: `AnalysisViewModel.State` cases for `idle`, `loading`, `success(AnalysisResult)`, and `failure(String)`

- [ ] **Step 1:** Add an `@MainActor`, `@Observable` view model that stores input, read-only state, and the injected service.
- [ ] **Step 2:** Deliberately omit the analyze action so the learner implements state transitions after understanding Swift concurrency.
- [ ] **Step 3:** Build with the existing Xcode scheme and require `BUILD SUCCEEDED`.
- [ ] **Step 4:** Commit with `feat: add analysis view model states`.

### Task 8: Final Verification and Push

**Files:**
- Verify: all files introduced by Tasks 1–7

**Interfaces:**
- Consumes: the complete eight-commit series
- Produces: a clean, buildable `main` branch on `origin`

- [ ] **Step 1:** Run `git diff --check 8ff8392..HEAD`.
- [ ] **Step 2:** Run the Debug simulator build and require `BUILD SUCCEEDED`.
- [ ] **Step 3:** Confirm `git rev-list --count 8ff8392..HEAD` returns `8` and no commit contains a contributor trailer.
- [ ] **Step 4:** Push `main` to `origin` and confirm the local branch matches `origin/main`.
