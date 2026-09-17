# MaxEnt v1 Evaluation

## Experiment

- Experiment: `maxent-v1`
- Created: 2026-09-17T12:23:54Z
- Dataset: `uci-sms-spam-collection-v1`
- Source SHA-256: `7d039a24a6083ed9ef0f806ebad56bbb976e3aeb8de05669173bfdc4996c239d`
- Split seed: `20260917`
- Model: `SpamClassifierMaxEnt` version `1.0.0`
- Algorithm: Core ML Maximum Entropy Text Classifier (revision 1)
- Language: English
- Training duration: 0.364 seconds
- Model size: 143456 bytes
- Model SHA-256: `e606d7910ffa8ff4decd523407a6c13e8f10f8bda0c2ea35ba97c00a73685b67`
- Median local inference latency: 0.029 ms

## Dataset and frozen split

Total prepared samples: 5574. Exact and normalized duplicates are grouped before the deterministic stratified split.

| Split | Total | Suspicious | Legitimate | Groups |
|---|---:|---:|---:|---:|
| training | 3903 | 524 | 3379 | 3586 |
| validation | 836 | 112 | 724 | 776 |
| holdout | 835 | 111 | 724 | 746 |

Duplicate groups: 316, containing 782 samples.

## Measured results

| Evaluation | Accuracy | Suspicious precision | Suspicious recall | Suspicious F1 | Confusion matrix |
|---|---:|---:|---:|---:|---|
| Majority holdout | 86.71% | 0.00% | 0.00% | 0.00% | TP 0 / FP 0 / TN 724 / FN 111 |
| Naive Bayes validation | 98.09% | 97.06% | 88.39% | 92.52% | TP 99 / FP 3 / TN 721 / FN 13 |
| Naive Bayes holdout | 99.04% | 99.05% | 93.69% | 96.30% | TP 104 / FP 1 / TN 723 / FN 7 |
| MaxEnt training | 100.00% | 100.00% | 100.00% | 100.00% | TP 524 / FP 0 / TN 3379 / FN 0 |
| MaxEnt validation | 96.89% | 93.88% | 82.14% | 87.62% | TP 92 / FP 6 / TN 718 / FN 20 |
| MaxEnt holdout | 97.72% | 94.23% | 88.29% | 91.16% | TP 98 / FP 6 / TN 718 / FN 13 |

## Incorrect holdout prediction review

Source message text is intentionally omitted from the committed report. Stable sample identifiers allow a local reviewer with the ignored source corpus to reproduce the review.

| Sample ID | Expected | Predicted | Confidence | Review category |
|---|---|---|---:|---|
| `0adb79b92a392a3b2be8b9366e19a9838edf603f23ed79e962cd0e9c800d2b27` | suspicious | legitimate | 71.24% | Identifier or transaction pattern |
| `0f6675f4f5a36e09e742696db1e961c92d2ecfdba82e82d9abaef390c2fa6d5b` | legitimate | suspicious | 75.17% | Limited message context |
| `213f12c2660962d664f1225fc699b5fe4ce363c48ed27c636df218c32727fcd8` | suspicious | legitimate | 66.68% | Suspicious pattern underweighted |
| `2428a0aabed972c77efa0920aa6825f0ad573db98ed1d37f78b2450109371768` | suspicious | legitimate | 100.00% | Suspicious pattern underweighted |
| `4b10fa91c9b64ee88302b883281a901d0c996a6ff36a7b5c9ad976083f31800f` | legitimate | suspicious | 84.34% | Identifier or transaction pattern |
| `67c94c5503c0b309d205a1a0b2a7073f9169503509a615d5aa0f49f6cf524049` | legitimate | suspicious | 97.35% | Identifier or transaction pattern |
| `7081a21ab1c0972de24f8fcbc2605ff3a58f1a8a2599897969318d59356ee373` | legitimate | suspicious | 94.46% | Limited message context |
| `70fd69899e09c2e43cbef3994a9a88fa1912f90266de224120170d8e210bf0bb` | suspicious | legitimate | 100.00% | Suspicious pattern underweighted |
| `7dbcb4dda5395f5ca15502def15f28e12149449b581da105decd8d602e2fc6c6` | suspicious | legitimate | 99.92% | Suspicious pattern underweighted |
| `8894cca4613733e5255f76316375abe879927bb4c18a426577aae894725607af` | suspicious | legitimate | 100.00% | Suspicious pattern underweighted |

## Demo messages

| Example | Actual prediction | Confidence |
|---|---|---:|
| Suspicious | suspicious | 95.15% |
| Legitimate | legitimate | 99.99% |
| Ambiguous | legitimate | 50.47% |

## Interpretation

Confidence is a model score, not certainty. This older English SMS benchmark does not represent all current scams, languages, regions, or conversational contexts. Results support an educational on-device demonstration and do not establish production readiness or safety advice.
