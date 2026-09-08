# Dataset Split and Leakage Policy

The dataset is split before learned preprocessing or model selection. This keeps the final test result independent from decisions made during development.

## Initial Split

Use a seeded, stratified group split:

| Split | Share | Purpose |
|---|---:|---|
| Training | 70% | Fit preprocessing and model parameters |
| Validation | 15% | Compare approaches and select settings |
| Test | 15% | Evaluate the frozen pipeline once |

The seed and dataset version must be recorded with the generated split. Exact row percentages may vary because every `group_id` stays together.

## Required Order

1. Validate required fields and remove unusable rows.
2. Normalize text only for duplicate detection.
3. Assign related messages to a shared `group_id`.
4. Split groups while preserving label balance as closely as possible.
5. Fit vocabulary, tokenization statistics, or other learned preprocessing on training data only.
6. Apply the fitted pipeline unchanged to validation and test data.

## Leakage Checks

- No `sample_id` or `group_id` appears in more than one split.
- Exact normalized-text duplicates remain in one split.
- Near-duplicate templates are reviewed and grouped before splitting.
- Source metadata, review notes, and label-derived fields are not model inputs.
- Validation results may guide iteration; test results may not guide retraining for the same reported run.
- Synthetic variations derived from one message inherit the source message's group and split.

## Why Grouping Comes First

Random row splitting can place nearly identical scam templates in both training and test data. The score then measures recognition of a known template instead of performance on unseen messages. Grouping reduces that false confidence.

## Evidence to Save

For each dataset version, save:

- split seed and ratio;
- row, group, label, and source counts per split;
- duplicate and near-duplicate checks;
- preprocessing configuration fitted from training data; and
- a checksum or version identifier for each split artifact.

If the test set is used to choose a model or threshold, retire it as the final test set and create a new untouched one before reporting final performance.
