# TinyKeyboard — App Icon Spec

## Status
No app icon exists yet. `TinyKeyboard/Assets.xcassets/AppIcon.appiconset/Contents.json` declares only the single universal 1024×1024 slot required by the current asset catalog format (Xcode 14+ single-size icon), but the PNG itself (`filename` entry) is missing. This needs a 1024×1024 PNG added before submission — App Store Connect will reject a build without one.

## Concept
A small keyboard silhouette that fades into transparency, visually asserting "the keyboard that isn't there."

- **Foreground**: a simplified, minimal keyboard glyph (2–3 rows of small rounded-rect keys, no legible letters — abstracted, not a literal keyboard screenshot) positioned in the lower two-thirds of the frame.
- **Fade**: the keyboard rows fade from full opacity/color at the bottom edge to blending fully into the background color by the top third — visually "dissolving," reinforcing invisibility, while the icon stays fully opaque (no alpha channel) throughout.
- **Background**: solid or subtly gradient background — dark graphite or deep indigo recommended for contrast on both iOS light and dark home screens. Avoid pure white/black per Apple HIG guidance (icons should not rely on transparency; App Store icons must be fully opaque with no alpha channel).
- **Color**: monochrome or duotone (e.g., graphite background, soft blue-white keys fading out) — keep it simple and legible at small sizes (the icon must read clearly at 60×60pt on a home screen, not just at 1024×1024).
- **No text/wordmark** in the icon — Apple discourages text in app icons, and "TinyKeyboard" as a wordmark won't be legible at small sizes anyway.

## Technical requirements
- 1024×1024 px, PNG, sRGB or Display P3, **no alpha channel** (fully opaque — App Store Connect rejects icons with transparency).
- No rounded corners baked in — iOS applies the corner mask automatically.
- Export flat (no layered PSD) into `TinyKeyboard/Assets.xcassets/AppIcon.appiconset/`, and add the filename to `Contents.json`'s `images[0].filename` key.

## Production note
This spec is written so the actual artwork can be produced with design tooling (Figma, Sketch, or an image generation tool) outside this session — no rendering/design tool was available here to produce the PNG directly.
