# Challenge6 ML Workflow

This workflow keeps product decisions, model experiments, and iOS integration traceable. A later stage may reveal a problem in an earlier stage; returning to fix it is expected.

Challenge6 completed this workflow for `maxent-v1`. The runnable native pipeline lives in `Scripts/Training`, the immutable aggregate record is `docs/modeling/experiments/maxent-v1.json`, and the full results are in `docs/modeling/maxent-v1-evaluation.md`.

```text
Problem -> Metric -> Data -> Baseline -> Training -> Validation -> Testing
   -> Conversion -> Integration -> Monitoring -> Feedback -> Improvement
```

## Stage Map

| Stage | Question to answer | Output | Evidence before moving on |
|---|---|---|---|
| Problem | Who needs help, in what situation, and what decision will the model support? | Narrow problem statement and non-goals | Research note and example user flow |
| Metric | What does a useful and safe result mean? | Primary metric and acceptable trade-offs | Metric definitions with rationale |
| Data | Does the dataset represent the problem consistently? | Versioned, documented dataset | Source, label, privacy, and quality notes |
| Baseline | What is the simplest result a trained model must beat? | Reproducible reference score | Baseline command, configuration, and metrics |
| Training | What does the model learn from? | Reproducible training artifact | Parameters, seed, data version, and run output |
| Validation | Which changes improve generalization? | Selected model configuration | Comparable validation results |
| Testing | How does the frozen choice perform on unseen data? | Final unbiased evaluation | Test metrics and confusion matrix |
| Conversion | Does the Core ML model preserve the original behavior? | `.mlmodel` or `.mlpackage` | Matching sample predictions and compatibility notes |
| Integration | Can the application request and present a prediction safely? | Working vertical slice | Device prediction, state handling, and failure behavior |
| Monitoring | What changes in quality, speed, or usage should be noticed? | Measurement plan | Metric definitions that preserve user privacy |
| Feedback | Which real mistakes are worth studying? | Reviewed error examples | Anonymized, consent-aware notes |
| Improvement | Which evidence justifies another iteration? | Prioritized experiment | Hypothesis linked to observed errors |

## Decision Gates

Do not train until the label meaning and split policy are written down. Do not integrate a converted model until its predictions are compared with the source model. Do not call the feature complete until correctness, performance, failure states, and limitations can be explained with evidence.

## Explain-Back Prompts

- Why can a good accuracy score still hide a harmful model?
- What information belongs to validation but not test-driven tuning?
- Where should text preprocessing live so training and inference remain consistent?
- Which evidence proves that conversion did not change model behavior?

## Reproducing the frozen run

1. Acquire and verify the official UCI archive using `docs/data/uci-sms-spam-collection.md`.
2. Run the preparation and metric contract checks with `./Scripts/run-training-checks.sh`.
3. Run `./Scripts/train-spam-classifier.sh` on macOS with `DEVELOPER_DIR` pointing to Xcode.
4. Review ignored output under `Scripts/Training/Output/maxent-v1`, including malformed-row diagnostics, duplicate groups, split overlap checks, local error details, and demo predictions.
5. Compare the generated report and JSON with the committed release. Do not replace the bundled model until a new experiment and version are intentionally approved.

The fixed seed makes grouping and split assignment reproducible. Create ML optimizer output can still vary across framework or OS versions, so every exported artifact keeps its own actual metrics, size, latency, and metadata.
