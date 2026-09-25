# Documentation Guide

Use this index to find the current product, engineering, and model notes. The root [README](../README.md) is the short project overview and run guide.

## Start with the app

| Guide | What it covers |
|---|---|
| [Academy demo and engineering guide](academy-demo-guide.md) | Presentation flow, current runtime architecture, privacy behavior, limitations, and troubleshooting |
| [MVVM learning guide](mvvm-learning-guide.md) | How the SwiftUI features, view models, and services fit together; written in Indonesian |

## Contribute safely

See the root [contributor guide](../CONTRIBUTING.md) for focused checks, data handling, and model release rules.

## Understand the model and data

| Guide | What it covers |
|---|---|
| [ML workflow](ml-workflow.md) | The end-to-end path from problem framing to a reviewed Core ML release |
| [UCI dataset provenance](data/uci-sms-spam-collection.md) | Source, license, checksums, and local acquisition instructions |
| [Message dataset contract](data/message-dataset-contract.md) | Prediction unit, labels, review rules, privacy, and required quality evidence |
| [Split and leakage policy](data/split-and-leakage.md) | Grouped train, validation, and holdout split rules |
| [Baseline evaluation](modeling/baseline-evaluation.md) | The transparent majority and Naive Bayes reference results |
| [MaxEnt v1 evaluation](modeling/maxent-v1-evaluation.md) | Frozen experiment metrics, error review, and limitations |
| [MaxEnt v1 experiment record](modeling/experiments/maxent-v1.json) | Structured configuration and aggregate results for the bundled model |

## Design history

The dated files under [`superpowers/specs`](superpowers/specs/) and [`superpowers/plans`](superpowers/plans/) preserve design decisions and implementation plans. Treat them as historical records; use the guides above and the shipped app as the source for current behavior.
