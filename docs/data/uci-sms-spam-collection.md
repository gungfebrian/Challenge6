# UCI SMS Spam Collection Provenance

Challenge6 uses the **SMS Spam Collection** as its primary public English training corpus. It is a pre-existing research dataset; this project did not collect the messages and does not claim ownership of them.

## Source and license

- Canonical record: <https://archive.ics.uci.edu/dataset/228/sms%2Bspam%2Bcollection>
- DOI: <https://doi.org/10.24432/C5CC84>
- Citation: Almeida, T. & Hidalgo, J. (2011). *SMS Spam Collection*. UCI Machine Learning Repository.
- License: [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/)
- Published size: 5,574 labeled English SMS messages
- Original labels: `spam` and `ham`
- Challenge6 labels: `suspicious` and `legitimate`

The machine-readable acquisition record is [`Data/Manifests/uci-sms-spam-v1.json`](../../Data/Manifests/uci-sms-spam-v1.json).

## Pinned acquisition

The dataset was retrieved on 2026-09-17 from UCI's HTTPS download endpoint.

| Artifact | SHA-256 |
|---|---|
| `sms+spam+collection.zip` | `1587ea43e58e82b14ff1f5425c88e17f8496bfcdb67a583dbff9eefaf9963ce3` |
| `SMSSpamCollection` | `7d039a24a6083ed9ef0f806ebad56bbb976e3aeb8de05669173bfdc4996c239d` |

Reproduce the local acquisition without changing the global Xcode toolchain:

```shell
mkdir -p .local-data/uci-sms-spam/raw
curl --fail --location --proto '=https' --tlsv1.2 \
  'https://archive.ics.uci.edu/static/public/228/sms+spam+collection.zip' \
  --output .local-data/uci-sms-spam/raw/sms-spam-collection.zip
shasum -a 256 .local-data/uci-sms-spam/raw/sms-spam-collection.zip
unzip .local-data/uci-sms-spam/raw/sms-spam-collection.zip \
  -d .local-data/uci-sms-spam/raw/extracted
shasum -a 256 .local-data/uci-sms-spam/raw/extracted/SMSSpamCollection
```

The `.local-data/` directory is gitignored. Do not stage its contents.

## Privacy boundary

Although this is a public licensed corpus, its conversational text contains names, phone-like strings, URLs, amounts, and other live-looking identifiers. The repository's [message dataset contract](message-dataset-contract.md) is stricter than simple public availability. For that reason:

- raw UCI messages remain local and uncommitted;
- the preparation tool replaces obvious identifiers with stable semantic placeholders before training;
- messages are assigned non-reversible SHA-256 sample and group identifiers;
- exact normalized duplicates stay together across train, validation, and holdout splits; and
- neither prepared rows nor split rows are committed unless a future privacy review explicitly changes this decision.

The committed model and aggregate reports cannot be used to reconstruct a supported list of source messages through an app feature. The app has no dataset browser, network upload, analytics, or cloud sync.

## Known limitations

- The corpus is from an older SMS collection context and contains language, abbreviations, and scam patterns associated with that period.
- It is English-focused and does not represent multilingual or regionally diverse usage.
- It does not cover all modern scams, messaging platforms, impersonation patterns, or conversational attacks.
- A message's intent can depend on sender identity and conversation context that the model does not receive.
- Strong performance on this benchmark does not demonstrate production readiness or guarantee that a message is safe.

These limitations must accompany model metrics and demo claims. The model output is an educational score, not professional safety advice.
