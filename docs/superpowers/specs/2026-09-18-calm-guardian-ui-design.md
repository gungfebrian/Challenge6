# Calm Guardian UI Design

## Product intent

Challenge6 remains a learning-first, privacy-conscious, on-device spam analysis demo. This redesign gives the existing product a calm, memorable visual identity while reducing the Check screen to three dominant zones: identity, input, and action. Successful analysis becomes a focused result sheet with verdict, confidence, and one concrete next step.

The classifier, Core ML artifact, history behavior, settings keys, privacy boundaries, and model metadata do not change.

## Visual direction

- Original message-shield mascot: a rounded speech bubble whose lower contour forms a shield point.
- Calm sky palette with opaque, high-contrast cards; no glassmorphism or neumorphism.
- System typography only. Rounded system design is reserved for titles and primary actions.
- Semantic colors:
  - Light: background `#F4F6FB`, surface `#FFFFFF`, ink `#16213A`, secondary `#5E6A82`, primary `#2D57D9`, safe `#136A4A`, warning `#A83C32`.
  - Sky: `#5E8CF0` to `#D9E4FF`, with cloud accent `#EEE9FF`.
  - Dark: background `#0D1424`, surface `#182238`, ink `#F6F8FF`, secondary `#B8C2D8`, primary `#9AB0FF`, safe `#64D4AC`, warning `#FF9A80`.
- Card radius 28 points, field radius 20 points, capsule primary actions, spacing scale 4/8/12/16/24/32.

## Check experience

### Identity zone

- Title: **Spam Check**
- Subtitle: **Check a message before you trust it.**
- Privacy pill: **Private • On-device**
- Idle or checking mascot centered beneath the copy.
- A 44-point question-mark control opens the educational sheet.

### Input zone

One opaque card contains a visible **Message** label, clear control, text editor, **English messages work best**, and one secondary **Try an example** action. The three examples remain fixed demonstration inputs and do not analyze automatically.

### Action zone

One full-width primary button reads **Check Message**. While the model runs it reads **Checking…**, is disabled, and the mascot uses its checking state.

Empty input focuses the editor and shows an inline error. Recoverable failures stay inline, retain the message, and expose Retry.

## Progressive disclosure

### Example picker

A medium native sheet lists Suspicious, Legitimate, and Ambiguous. Selecting a row fills the editor and dismisses the sheet.

### Educational help

The **How Spam Check works** sheet states:

1. The model was trained on 5,574 labeled English SMS messages from the UCI SMS Spam Collection.
2. The three demo examples are new walkthrough messages, not training records.
3. Analysis runs locally and messages are not uploaded.
4. The dataset is older and English-focused; confidence is a score, not certainty.

It links to the existing full Model & Dataset Information screen.

### Result sheet

The result sheet contains only three dominant elements:

1. Safe or warning mascot plus **Likely Not Spam** or **Likely Spam**.
2. Large percentage labeled **Model confidence**.
3. One recommendation card.

Suspicious recommendation:

- **Pause before you act**
- **Don’t tap links or share codes. Verify the sender another way.**

Legitimate recommendation:

- **Still stay alert**
- **Verify unexpected requests, especially about money or account access.**

Model name/version and the uncertainty explanation live in a collapsed **Learn more** disclosure. **Check Another Message** dismisses and resets the flow. Interactive sheet dismissal has the same reset behavior.

## Mascot asset prompt

```text
Use case: stylized-concept
Asset type: iOS app mascot anchor illustration
Primary request: an original friendly “message-shield buddy,” formed from a rounded speech bubble whose lower contour becomes a small shield point
Subject: compact cobalt-blue character, periwinkle highlights, tiny navy face, soft rounded proportions, two subtle mitten-like hands
Style/medium: polished soft 3D clay-style illustration with a clean vector-like silhouette
Composition/framing: centered three-quarter view with generous padding
Lighting/mood: soft daylight, calm, trustworthy, friendly rather than childish
Color palette: cobalt blue, periwinkle, white, navy; mint only as a positive accent
Constraints: genuinely transparent background; no text; no logo; no watermark; no resemblance to an existing brand character
```

Checking, safe, and warning assets preserve the anchor character exactly. The app icon uses a close crop of the same character on an opaque full-bleed background, without pre-rounded corners or text.

## Accessibility and adaptability

- Every control is at least 44 by 44 points.
- Result meaning always includes icon/mascot and text; color is supplementary.
- Dynamic Type uses semantic styles and may reflow without truncating essential copy.
- VoiceOver order follows identity, privacy, message, examples, and primary action; result order follows verdict, confidence, recommendation, details, and action.
- Idle float and checking pulse stop when Reduce Motion is enabled.
- Light and dark palettes meet 4.5:1 for normal text and 3:1 for meaningful graphics.
- Lists, forms, keyboard content, tab bars, and sheets respect safe areas on iPhone, iPad, and landscape.

