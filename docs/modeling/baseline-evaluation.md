# Baseline and Evaluation Contract

The baseline answers whether training a model adds value and gives every later experiment a reproducible comparison point. Model selection uses validation data; the test set remains untouched until the pipeline is frozen.

## Baseline Order

1. **Majority-class baseline:** always predict the most common training label. This exposes how misleading accuracy can be on an imbalanced dataset.
2. **Simple text baseline:** train a small, explainable text classifier with preprocessing fitted only on training data.
3. **Core ML candidate:** compare a Create ML or converted model only after the simple baseline is understood.

A more complex model is selected only when its measured improvement is meaningful for the product and worth its size, latency, and debugging cost.

## Evaluation Metrics

| Metric | What it reveals | Why it matters here |
|---|---|---|
| Suspicious-class precision | How often a suspicious prediction is correct | Low precision can create warning fatigue |
| Suspicious-class recall | How many suspicious messages are detected | Low recall leaves more harmful messages unnoticed |
| F1 score | Balance between precision and recall | Supports comparison when labels are imbalanced |
| Confusion matrix | Counts for every actual/predicted pair | Makes error direction visible |
| Accuracy | Overall correct share | Useful only beside class balance and per-class metrics |
| On-device latency | Time for one prediction | Confirms the interaction remains responsive |
| Model size | Storage added to the application | Captures a deployment trade-off |

Do not invent a passing threshold before dataset research establishes realistic costs and class balance. Record the chosen threshold and its reasoning before final testing.

## Experiment Record

Each run should preserve:

- experiment identifier and date;
- dataset and split versions;
- preprocessing configuration;
- model type and parameters;
- random seed;
- validation metrics;
- training duration; and
- artifact location or checksum.

## Comparison Table

Record one row per completed experiment using the same validation split.

| Run | Model | Precision | Recall | F1 | Accuracy | Size | Latency | Decision |
|---|---|---:|---:|---:|---:|---:|---:|---|
| Majority baseline | Most frequent training label | Measured during the run | Measured during the run | Measured during the run | Measured during the run | Not applicable | Not applicable | Reference only |

## Error Analysis

Review at least ten wrong validation predictions before changing the model. Include both false positives and false negatives. For each, record the expected label, predicted label, confidence if available, likely error category, and one evidence-based next experiment.

Common categories to investigate include ambiguous wording, missing conversational context, unfamiliar message patterns, source imbalance, label disagreement, preprocessing mismatch, and duplicate leakage. Categories describe observations; they do not prove a cause without further testing.

## Final Test Gate

Freeze the data pipeline, model configuration, and decision threshold before opening test results. Report the full confusion matrix and all agreed metrics, including disappointing results. A failed target is evidence for the next iteration, not a reason to tune against the test set.
