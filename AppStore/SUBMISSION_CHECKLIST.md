# App Store submission checklist

Prepared 2026-09-06 on branch `fm/tiny-appstore-prep`. **Do not upload to App Store Connect** — the app record does not exist yet.

## Ready

- **App icon** — 1024×1024 sRGB PNG, no alpha, no baked corners, wired in `AppIcon.appiconset/Contents.json`. Generator: `scripts/generate-app-icon.py`.
- **iPhone 6.9" screenshots** — 1320×2868 RGB, four shots in `AppStore/screenshots/iphone-6.9/`.
- **iPad 13" screenshots** — 2064×2752 RGB, four shots in `AppStore/screenshots/ipad-13/` (required while the binary is `TARGETED_DEVICE_FAMILY = 1,2`).
- **App Store copy** — name, subtitle, description, keywords, category, age rating, pricing in `Plans/app-store-copy.md`.
- **Reviewer note** — in `Plans/app-store-copy.md`. Checked against the code:
  - 1pt transparent input view (`KeyboardViewController`)
  - `needsInputModeSwitchKey` globe fallback calling `advanceToNextInputMode()`
  - system dock is the practical switcher
  - host app onboarding + Open App Settings
  - `RequestsOpenAccess = false`
  The note is accurate. Reviewers should add the keyboard in Settings and switch with the globe; invisibility is intended.
- **Entitlements / capabilities**
  - `TinyKeyboard.entitlements` — empty dict (no App Groups, no network, no associated domains)
  - `TinyKeyboardExtension.entitlements` — empty dict
  - Simulator-signed binaries also report empty entitlements
  - Keyboard extension: `NSExtensionPointIdentifier = com.apple.keyboard-service`
  - `RequestsOpenAccess = false` — no Full Access prompt, matches the zero-collection privacy claim
- **Privacy policy file** — `privacy-policy.html` at repo root (text matches the in-app screen).
- **Signing** — not touched. Team `TV2582LRYN`, bundle `com.trillium.TinyKeyboard` / `.keyboard`.

## Needs a human decision (not done here)

1. **App Store Connect record** — create the app (name TinyKeyboard, bundle `com.trillium.TinyKeyboard`, SKU, primary locale). Do not upload a build until the record exists.
2. **iPad scope** — `SPEC.md` says iPad is a non-goal, but both targets are `TARGETED_DEVICE_FAMILY = 1,2`. Either keep iPad (screenshots already captured) or change family to `1` (iPhone only) before the first archive you submit. Do not mix that with a signing/team edit.

## Still missing (cannot finish without the items above)

- App Store Connect app record, privacy nutrition labels ("Data Not Collected"), and the reviewer notes field paste (Privacy Policy URL: `https://trillium.github.io/TinyKeyboard/privacy-policy.html`)
- Archive + upload of a Release build (explicitly out of scope for this prep)
- Caption overlays ("Your screen stays yours.") — copy mentions a caption; the files here are raw simulator shots, which App Store Connect accepts
- Host-app "Not enabled yet" badge stays orange even after TinyKeyboard is the active keyboard (`UITextInputMode.activeInputModes` lag / identifier mismatch). Cosmetic for screenshots; not a submission blocker

## Not missing

- No Full Access / Open Access capability to declare
- No IAP, no tracking, no encryption-beyond-HTTPS questionnaire trigger (the app makes no network calls)
