# Challenge6

Challenge6 is a SwiftUI application that is currently in its foundation stage. The repository is intentionally small so product features can be added without carrying premature architecture or dependencies.

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

## Project structure

```text
Challenge6/
├── App/             # Application entry point and app-wide composition
├── Features/        # Product code grouped by feature
└── Resources/       # Asset catalogs and other bundled resources
```

## Status

The project contains repository and application foundations only. Product behavior will be introduced in later work.
