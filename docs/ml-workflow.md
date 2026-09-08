# Industry ML Workflow

This workflow keeps product decisions, model experiments, and iOS integration traceable. A later stage may reveal a problem in an earlier stage; returning to fix it is expected.

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
