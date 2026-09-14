# Challenge6

Challenge6 is a learning-first SwiftUI application for exploring an on-device spam-analysis flow. It contains one small, runnable MVVM feature and a readable Multinomial Naive Bayes implementation without third-party dependencies.

## Requirements

- Xcode 26.6 or later
- iOS 26.5 or later

## Getting started

1. Clone the repository.
2. Open `Challenge6.xcodeproj` in Xcode.
3. Select the `Challenge6` scheme and an iOS Simulator.
4. Build and run with **Command-R**.

## Development principles

- Keep app startup code separate from feature code.
- Group files by feature as the product grows.
- Put shared visual primitives in the design system.
- Prefer native SwiftUI and system APIs before adding dependencies.
- Keep every commit focused and leave the project buildable.

## Learn MVVM

Read the [Indonesian MVVM and file-structure guide](docs/mvvm-learning-guide.md) before expanding the feature. It explains every folder, traces one complete interaction, documents the accessibility choices, and provides exercises in increasing difficulty.

The app currently uses `MultinomialNaiveBayesService`, which trains a readable classifier from a tiny embedded teaching dataset. This keeps the algorithm observable while learning; it is not a production model and must not be treated as safety advice.

## Project structure

```text
Challenge6/
├── App/                         # Application entry point and dependency composition
├── DesignSystem/                # Reusable visual foundations
├── Features/
│   └── Analysis/
│       ├── Models/              # Stable feature data
│       ├── Services/            # Protocol and concrete implementations
│       ├── ViewModels/          # UI state and actions
│       └── Views/               # SwiftUI presentation
└── Resources/                   # Asset catalogs and bundled resources
```

## Status

The project demonstrates input validation, asynchronous state transitions, dependency injection, accessible UI feedback, tokenization, Laplace smoothing, log-probability scoring, and a replaceable service boundary. A converted Core ML model and production-quality training data remain future learning steps.

## Classifier checks

Run the focused algorithm checks without launching the app:

```shell
./Scripts/run-classifier-checks.sh
```
