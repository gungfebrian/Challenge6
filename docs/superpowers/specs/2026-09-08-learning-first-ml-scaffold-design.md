# Learning-First ML Scaffold

## Purpose

Challenge6 will become an on-device iOS application that helps people examine suspicious messages without sending their text to a server. This change creates only the first learning scaffold. It must make the intended architecture visible without completing work that the learner should practice during the ten-day challenge.

## Scope

This scaffold will:

- document the ML lifecycle used by the project;
- define the initial dataset contract, labels, split policy, and baseline criteria;
- introduce small Swift domain types for an analysis request and result;
- define an asynchronous service protocol that can later hide Core ML details; and
- introduce an intentionally incomplete view model with explicit inference states.

It will not include a trained model, Core ML model file, production inference service, finished analysis screen, persistence, networking, analytics, or a complete solution to any curriculum exercise.

## Approach

Use a learning-first scaffold rather than starting with the interface or a complete architecture. Data decisions come before model and application code because label ambiguity or leakage cannot be repaired by a polished SwiftUI layer. The small code boundary added at the end gives the learner a concrete place to integrate later work while leaving that implementation open.

Two alternatives were rejected for now:

- **UI-first:** provides a fast visual result but encourages designing around output that has not yet been defined by model evaluation.
- **Architecture-first:** adds mocks, persistence, and dependency injection early, but hides the core ML learning goal behind application infrastructure.

## Architecture Boundary

The eventual data flow remains:

```text
User Input -> SwiftUI View -> ViewModel -> MLService -> Core ML -> Result
```

This scaffold stops at the protocol boundary. The view model may validate input and represent `idle`, `loading`, `success`, and `failure`, but it must not contain Core ML APIs or message-classification rules. A future concrete service will own model loading, preprocessing, prediction, and output mapping.

## Error Handling

Errors crossing the service boundary should be domain-oriented and safe to display or translate. Framework-specific failures remain inside the future service. Empty input is a view-model validation concern because no inference should be started for it.

## Documentation Style

Documents record decisions, evidence expectations, and questions for the learner. Swift comments explain why a boundary exists when the reason is not obvious. Comments must not narrate syntax or provide tutorial-sized implementations.

## Verification

Documentation commits are checked for internal consistency and placeholders. Swift commits must compile with the existing `Challenge6` scheme. The final history must contain exactly eight new focused commits and a clean working tree before pushing.

## Planned Commit Series

1. `docs: define learning-first ML scaffold`
2. `docs: map the industry ML workflow`
3. `docs: define the message dataset contract`
4. `docs: document split and leakage rules`
5. `docs: define baseline evaluation criteria`
6. `feat: add analysis domain types`
7. `feat: define the ML service boundary`
8. `feat: add analysis view model states`

Each commit should remain useful and understandable on its own. No commit will include assistant attribution or contributor trailers.
