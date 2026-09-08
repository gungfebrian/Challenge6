# Message Dataset Contract

This contract defines what one training example means before messages are collected or transformed. The labels are provisional until Academy research confirms that the problem and language match real user needs.

## Prediction Unit

One row represents one complete message as a user would analyze it. Do not split a message into sentences because that changes the context available to both the model and the user.

| Field | Type | Rule | Why it exists |
|---|---|---|---|
| `sample_id` | String | Stable, unique, and unrelated to row order | Tracks a sample without using message text as identity |
| `text` | String | Original message text after documented privacy cleanup | Contains the model input |
| `label` | String | `suspicious` or `legitimate` | Defines the provisional prediction target |
| `group_id` | String | Shared by duplicates, templates, and related variants | Keeps related examples in one split |
| `source` | String | Controlled source category, not personal identity | Supports provenance and coverage checks |
| `review_status` | String | `single_review`, `agreed`, or `needs_review` | Makes label confidence visible |

## Provisional Labels

### `suspicious`

Use when the message attempts or strongly prepares to obtain money, credentials, sensitive information, or an unsafe action through deception, impersonation, urgency, or manipulation.

### `legitimate`

Use when the message has a credible ordinary purpose and lacks evidence of deceptive or manipulative intent. A message is not automatically legitimate merely because it lacks obvious scam keywords.

### Ambiguous Messages

Mark disputed or context-dependent messages as `needs_review`. Exclude them from the first training run instead of forcing a label. Keep the original review notes outside the model input.

## Annotation Rules

1. Read the complete message before assigning a label.
2. Judge the message's behavior, not spelling quality or writing style alone.
3. Do not assume that every request involving money, links, or urgency is suspicious.
4. Assign the same `group_id` to copied templates and lightly edited variants.
5. Require a second review for examples used in the final evaluation set.

## Privacy and Exclusions

- Use public, licensed, synthetic, or explicitly consented data only.
- Remove names, phone numbers, account identifiers, addresses, and live credentials before storage.
- Do not commit raw personal messages to this repository.
- Record the source category and usage permission for every collected batch.
- Exclude empty, unreadable, unlabeled, and unresolved examples from modeling.

## Quality Evidence

Before the first split, record label counts, source counts, duplicate-group counts, unresolved-review counts, and the language coverage of the dataset. These numbers reveal imbalance and missing coverage before they become model errors.
