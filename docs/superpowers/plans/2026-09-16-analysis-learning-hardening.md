# Analysis Learning Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing SwiftUI MVVM and Multinomial Naive Bayes implementation easier to understand, safer to change, and better tested without changing its dataset, primary predictions, or visual design.

**Architecture:** Keep the existing feature-first MVVM flow. Extract small ML value types so tokenization, sparse counts, score selection, and training validation are explicit; retain `MLService` as the ViewModel boundary; add executable tests for both classifier and ViewModel state transitions.

**Tech Stack:** Swift 5 language mode, SwiftUI, Observation, Foundation, shell-driven `swiftc` checks, Git.

**Spec:** User-confirmed scope in the 2026-09-16 conversation: Analysis feature only; learning-first then production-quality; preserve the 12-example dataset, main predictions, and current UI; produce exactly 17 meaningful commits directly on `main` with no Codex attribution.

## Global Constraints

- Work directly on `main` because the user explicitly requested it.
- Create exactly 17 non-empty, independently reviewable commits including this plan.
- Preserve the existing 12 training examples and user-visible design.
- Add no third-party dependencies.
- Use test-first red-green cycles for new behavior and mutation checks for characterization tests.
- Run `./Scripts/run-classifier-checks.sh` before every implementation commit.
- Do not stage `Codex Image Sep 15, 2026, 03_34_41 PM.png` or `Rencana_Skripsi_Politik_Perizinan_Nikel_Raja_Ampat.docx`.
- Use the configured Git author without co-author trailers.

---

### Task 1: Record the implementation plan

**Files:**
- Create: `docs/superpowers/plans/2026-09-16-analysis-learning-hardening.md`

**Interfaces:**
- Consumes: Current repository structure and user-confirmed constraints.
- Produces: The ordered 17-commit execution contract.

- [ ] **Step 1: Verify the baseline**

Run: `./Scripts/run-classifier-checks.sh`

Expected: `Classifier checks passed`.

- [ ] **Step 2: Commit the plan**

```bash
git add docs/superpowers/plans/2026-09-16-analysis-learning-hardening.md
git commit -m "docs: plan analysis learning hardening"
```

### Task 2: Extract the executable test harness

**Files:**
- Create: `Tests/Challenge6CoreTests/TestSupport.swift`
- Create: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Tests/Challenge6CoreTests/MultinomialNaiveBayesClassifierTests.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Consumes: Existing `expect` helper and classifier test entry point.
- Produces: `expect(_:_:)`, `expectApproximatelyEqual(_:_:tolerance:_:)`, and a single suite entry point able to call additional test files.

- [ ] **Step 1: Move assertions into `TestSupport.swift`**

```swift
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
}

func expectApproximatelyEqual(
    _ actual: Double,
    _ expected: Double,
    tolerance: Double = 0.000_001,
    _ message: String
) {
    expect(abs(actual - expected) < tolerance, message)
}
```

- [ ] **Step 2: Make classifier tests expose `run()` instead of `@main`**

```swift
enum MultinomialNaiveBayesClassifierTests {
    static func run() async {
        let classifier = MultinomialNaiveBayesClassifier(
            trainingExamples: [
                .init(text: "win cash cash", label: .suspicious),
                .init(text: "team meeting", label: .legitimate)
            ]
        )
        let prediction = classifier.predict(text: "cash cash")
        expect(prediction.label == .suspicious, "Repeated suspicious words should produce a suspicious label")
        expectApproximatelyEqual(
            prediction.confidence,
            324.0 / 373.0,
            "Confidence should match the hand-calculated probability"
        )
        await checkLearningServiceExamples()
    }
}
```

- [ ] **Step 3: Add the shared test entry point**

```swift
@main
enum Challenge6CoreTests {
    static func main() async {
        await MultinomialNaiveBayesClassifierTests.run()
        print("Challenge6 checks passed")
    }
}
```

- [ ] **Step 4: Compile all test support files in the runner and verify**

Run: `./Scripts/run-classifier-checks.sh`

Expected: `Challenge6 checks passed`.

- [ ] **Step 5: Commit**

```bash
git commit -am "test: extract the core test harness"
git add Tests/Challenge6CoreTests/TestSupport.swift Tests/Challenge6CoreTests/TestMain.swift
git commit --amend --no-edit
```

### Task 3: Extract text tokenization

**Files:**
- Create: `Challenge6/Features/Analysis/Services/TextTokenizer.swift`
- Create: `Tests/Challenge6CoreTests/TextTokenizerTests.swift`
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `TextTokenizer.tokens(in: String) -> [String]`.

- [ ] **Step 1: Write the failing tokenizer test**

```swift
enum TextTokenizerTests {
    static func run() {
        expect(
            TextTokenizer.tokens(in: "URGENT! click-now 42") == ["urgent", "click", "now", "42"],
            "Tokenizer should normalize case and split punctuation"
        )
    }
}
```

- [ ] **Step 2: Run RED**

Run: `./Scripts/run-classifier-checks.sh`

Expected: compile failure because `TextTokenizer` does not exist.

- [ ] **Step 3: Add the implementation and use it in the classifier**

```swift
enum TextTokenizer {
    static func tokens(in text: String) -> [String] {
        text.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init)
    }
}
```

- [ ] **Step 4: Run GREEN and commit**

Run: `./Scripts/run-classifier-checks.sh`

```bash
git add Challenge6 Tests Scripts
git commit -m "refactor: extract text tokenization"
```

### Task 4: Introduce sparse token counts

**Files:**
- Create: `Challenge6/Features/Analysis/Services/TokenBag.swift`
- Create: `Tests/Challenge6CoreTests/TokenBagTests.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `TokenBag.init(tokens:)`, `counts`, `totalCount`, and `keeping(_:)`.

- [ ] **Step 1: Write failing tests for repeated tokens and vocabulary filtering**

```swift
let bag = TokenBag(tokens: ["cash", "meeting", "cash"])
expect(bag.counts == ["cash": 2, "meeting": 1], "TokenBag should count repeats")
expect(bag.totalCount == 3, "TokenBag should retain the total token count")
expect(bag.keeping(["cash"]).counts == ["cash": 2], "TokenBag should filter vocabulary")
```

- [ ] **Step 2: Run RED, implement the value type, run GREEN, and commit**

Run before implementation: `./Scripts/run-classifier-checks.sh`

```swift
struct TokenBag: Equatable, Sendable {
    let counts: [String: Int]
    var totalCount: Int { counts.values.reduce(0, +) }

    init(tokens: [String]) {
        counts = tokens.reduce(into: [:]) { counts, token in
            counts[token, default: 0] += 1
        }
    }

    private init(counts: [String: Int]) {
        self.counts = counts
    }

    func keeping(_ vocabulary: Set<String>) -> TokenBag {
        TokenBag(counts: counts.filter { vocabulary.contains($0.key) })
    }
}
```

Run after implementation: `./Scripts/run-classifier-checks.sh`

Commit: `refactor: add sparse token bags`

### Task 5: Train from token bags

**Files:**
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift`

**Interfaces:**
- Consumes: `TextTokenizer.tokens(in:)`, `TokenBag`.
- Produces: Equivalent class statistics using explicit sparse counts.

- [ ] **Step 1: Run the current suite as the refactor safety net**

Run: `./Scripts/run-classifier-checks.sh`

- [ ] **Step 2: Change `ClassStatistics.observe` to accept `TokenBag`**

```swift
mutating func observe(_ tokenBag: TokenBag) {
    documentCount += 1
    tokenCount += tokenBag.totalCount
    for (token, count) in tokenBag.counts {
        countsByToken[token, default: 0] += count
    }
}
```

- [ ] **Step 3: Run the suite and commit**

Commit: `refactor: train from sparse token counts`

### Task 6: Score prediction token bags

**Files:**
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift`

**Interfaces:**
- Consumes: `TokenBag.keeping(_:)`.
- Produces: Mathematically equivalent frequency-weighted log scores.

- [ ] **Step 1: Keep the hand-calculated confidence test as the safety constraint**

Expected literal: `324.0 / 373.0` for `cash cash`.

- [ ] **Step 2: Replace repeated-token reduction with frequency weighting**

```swift
return tokenBag.counts.reduce(log(prior)) { score, entry in
    let (token, frequency) = entry
    let observedCount = Double(statistics.countsByToken[token, default: 0])
    let likelihood = (observedCount + smoothing) / denominator
    return score + Double(frequency) * log(likelihood)
}
```

- [ ] **Step 3: Run the suite and commit**

Commit: `refactor: score sparse prediction counts`

### Task 7: Isolate binary score selection

**Files:**
- Create: `Challenge6/Features/Analysis/Services/PredictionScores.swift`
- Create: `Tests/Challenge6CoreTests/PredictionScoresTests.swift`
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `PredictionScores(suspicious:legitimate:).result` with legitimate tie-breaking and normalized confidence.

- [ ] **Step 1: Write tests for winner normalization and ties**

```swift
expect(PredictionScores(suspicious: 2, legitimate: 1).result.label == .suspicious, "Higher score should win")
expect(PredictionScores(suspicious: 1, legitimate: 1).result.label == .legitimate, "Ties should preserve the existing legitimate fallback")
```

- [ ] **Step 2: Run RED, implement, integrate, run GREEN, and commit**

Commit: `refactor: isolate prediction score selection`

### Task 8: Extract the bundled training dataset

**Files:**
- Create: `Challenge6/Features/Analysis/Services/SpamTrainingDataset.swift`
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesService.swift`

**Interfaces:**
- Produces: `SpamTrainingDataset.examples` containing the unchanged 12 examples.

- [ ] **Step 1: Move the exact examples without editing their text or labels**

```swift
enum SpamTrainingDataset {
    static let examples: [MultinomialNaiveBayesClassifier.TrainingExample] = [
        .init(text: "Congratulations winner claim your cash prize click the link now", label: .suspicious),
        .init(text: "Urgent verify your bank account password immediately", label: .suspicious),
        .init(text: "Limited offer get a free gift claim today", label: .suspicious),
        .init(text: "Your package is held pay the delivery fee now", label: .suspicious),
        .init(text: "Act now to avoid account suspension click to verify", label: .suspicious),
        .init(text: "You are selected as a winner send your personal details", label: .suspicious),
        .init(text: "Can we move our team meeting to tomorrow morning", label: .legitimate),
        .init(text: "Dinner is ready see you at home tonight", label: .legitimate),
        .init(text: "Your dentist appointment is Tuesday at ten", label: .legitimate),
        .init(text: "Thanks for sending the project notes", label: .legitimate),
        .init(text: "Please review the document before our class", label: .legitimate),
        .init(text: "Remember to buy milk and bread on your way home", label: .legitimate)
    ]
}
```

- [ ] **Step 2: Run the suite and commit**

Commit: `refactor: extract the spam training dataset`

### Task 9: Validate classifier training configuration

**Files:**
- Create: `Challenge6/Features/Analysis/Services/TrainingDataValidator.swift`
- Create: `Tests/Challenge6CoreTests/TrainingDataValidatorTests.swift`
- Modify: `Challenge6/Features/Analysis/Services/MultinomialNaiveBayesClassifier.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `TrainingDataIssue` and `TrainingDataValidator.issue(examples:smoothing:)`.

- [ ] **Step 1: Write failing tests**

```swift
expect(TrainingDataValidator.issue(examples: [], smoothing: 1) == .missingSuspiciousLabel, "Suspicious examples are required")
expect(TrainingDataValidator.issue(examples: [.init(text: "spam", label: .suspicious)], smoothing: 1) == .missingLegitimateLabel, "Legitimate examples are required")
expect(TrainingDataValidator.issue(examples: SpamTrainingDataset.examples, smoothing: 0) == .nonPositiveSmoothing, "Smoothing must be positive")
```

- [ ] **Step 2: Run RED, implement validator, use it before training, run GREEN, and commit**

Commit: `feat: validate classifier training data`

### Task 10: Make the service boundary concurrency-safe

**Files:**
- Modify: `Challenge6/Features/Analysis/Services/MLService.swift`
- Modify: conforming services only if the compiler requires changes.

**Interfaces:**
- Produces: `protocol MLService: Sendable`.

- [ ] **Step 1: Add `Sendable` to the protocol**

```swift
protocol MLService: Sendable {
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult
}
```

- [ ] **Step 2: Run the suite and commit**

Commit: `refactor: make ML services sendable`

### Task 11: Centralize request normalization

**Files:**
- Modify: `Challenge6/Features/Analysis/Models/AnalysisRequest.swift`
- Modify: `Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift`
- Create: `Tests/Challenge6CoreTests/AnalysisRequestTests.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `AnalysisRequest.init?(rawText:)` while retaining `init(text:)`.

- [ ] **Step 1: Write failing normalization tests**

```swift
expect(AnalysisRequest(rawText: "  hello\n")?.text == "hello", "Request should trim boundaries")
expect(AnalysisRequest(rawText: "  \n") == nil, "Request should reject blank input")
```

- [ ] **Step 2: Run RED, implement the initializer, update ViewModel, run GREEN, and commit**

Commit: `refactor: centralize analysis input normalization`

### Task 12: Represent ViewModel failures with a domain enum

**Files:**
- Modify: `Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift`
- Modify: `Challenge6/Features/Analysis/Views/AnalysisStatusView.swift`
- Create: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`
- Modify: `Tests/Challenge6CoreTests/TestMain.swift`
- Modify: `Scripts/run-classifier-checks.sh`

**Interfaces:**
- Produces: `AnalysisViewModel.Failure.emptyInput`, `.serviceUnavailable`, and `message`.

- [ ] **Step 1: Write a failing empty-input state test using a service that traps if called**

```swift
let viewModel = AnalysisViewModel(mlService: UnexpectedCallService())
viewModel.message = "   "
await viewModel.analyze()
expect(viewModel.state == .failure(.emptyInput), "Blank input should produce a typed failure")
```

- [ ] **Step 2: Run RED, implement typed failures and rendering, run GREEN, and commit**

Commit: `refactor: model analysis failures explicitly`

### Task 13: Protect the successful ViewModel transition

**Files:**
- Modify: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`

**Interfaces:**
- Consumes: `AnalysisViewModel.analyze()` and `RecordingMLService` actor.
- Produces: Regression coverage for trimmed requests and `.success`.

- [ ] **Step 1: Add a success test with a literal expected result**

```swift
let expected = AnalysisResult(label: .suspicious, confidence: 0.82)
let service = RecordingMLService(result: expected)
let viewModel = AnalysisViewModel(mlService: service)
viewModel.message = "  urgent click  "
await viewModel.analyze()
expect(viewModel.state == .success(expected), "Successful analysis should publish its result")
expect(await service.receivedText == "urgent click", "ViewModel should send normalized input")
```

- [ ] **Step 2: Mutation-check RED by temporarily replacing the success assignment with `.idle`**

Run: `./Scripts/run-classifier-checks.sh`

Expected: failure naming the success transition. Restore production code.

- [ ] **Step 3: Run GREEN and commit**

Commit: `test: cover successful analysis state`

### Task 14: Protect the service-error transition

**Files:**
- Modify: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`

**Interfaces:**
- Produces: Regression coverage for `.failure(.serviceUnavailable)`.

- [ ] **Step 1: Add a throwing service test**

```swift
let viewModel = AnalysisViewModel(mlService: FailingMLService())
viewModel.message = "hello"
await viewModel.analyze()
expect(viewModel.state == .failure(.serviceUnavailable), "Service errors should be renderable failures")
```

- [ ] **Step 2: Mutation-check RED, restore, run GREEN, and commit**

Commit: `test: cover analysis service failures`

### Task 15: Protect the cancellation transition

**Files:**
- Modify: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`

**Interfaces:**
- Produces: Regression coverage for cancellation returning to `.idle`.

- [ ] **Step 1: Add a service that throws `CancellationError`**

```swift
let viewModel = AnalysisViewModel(mlService: CancellingMLService())
viewModel.message = "hello"
await viewModel.analyze()
expect(viewModel.state == .idle, "Cancellation should restore idle state")
```

- [ ] **Step 2: Mutation-check RED, restore, run GREEN, and commit**

Commit: `test: cover analysis cancellation`

### Task 16: Ignore results for input that changed in flight

**Files:**
- Modify: `Challenge6/Features/Analysis/ViewModels/AnalysisViewModel.swift`
- Modify: `Tests/Challenge6CoreTests/AnalysisViewModelTests.swift`

**Interfaces:**
- Consumes: A controlled async ML service.
- Produces: Stale result protection that restores `.idle` if `message` changed while awaiting the service.

- [ ] **Step 1: Write the failing controlled-service test**

```swift
let service = ControlledMLService()
let viewModel = AnalysisViewModel(mlService: service)
viewModel.message = "first"
let task = Task { await viewModel.analyze() }
await service.waitUntilRequested()
viewModel.message = "second"
await service.succeed(with: AnalysisResult(label: .suspicious, confidence: 0.9))
await task.value
expect(viewModel.state == .idle, "A stale result should not replace state for newer input")
```

- [ ] **Step 2: Run RED, guard the request text before publishing success, run GREEN, and commit**

Commit: `fix: ignore stale analysis results`

### Task 17: Refresh the learning guide

**Files:**
- Modify: `docs/mvvm-learning-guide.md`

**Interfaces:**
- Consumes: Final code structure.
- Produces: A concise reconstruction order and updated ML boundary map.

- [ ] **Step 1: Document the final flow and extracted ML value types**

Include these exact concepts: `TextTokenizer`, `TokenBag`, `PredictionScores`, `TrainingDataValidator`, typed ViewModel failures, and stale-result protection.

- [ ] **Step 2: Run final verification**

```bash
./Scripts/run-classifier-checks.sh
git diff --check HEAD~16..HEAD
git status --short
```

Expected: all checks pass; only the two unrelated untracked personal files remain.

- [ ] **Step 3: Commit**

Commit: `docs: refresh the analysis reconstruction guide`

- [ ] **Step 4: Verify exactly 17 commits and push**

```bash
git log --oneline HEAD~17..HEAD
git fetch origin
git push origin main
git rev-list --left-right --count main...origin/main
```

Expected: 17 commits listed and final divergence `0 0`.
