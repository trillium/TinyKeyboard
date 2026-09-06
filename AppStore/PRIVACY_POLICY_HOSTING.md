# Privacy policy — public URL (needs a repo-settings click)

The static page is already in the repo:

- File: [`privacy-policy.html`](../privacy-policy.html) (repo root)
- Intended public URL after GitHub Pages is enabled:
  `https://trillium.github.io/TinyKeyboard/privacy-policy.html`

App Store Connect requires a **public** privacy-policy URL. The in-app `PrivacyPolicyView` does not satisfy that. Tailscale OTA (`tailscale serve`) is tailnet-only and does not qualify.

GitHub Pages is **enabled** (2026-09-06): source `main` / `(root)`, HTTPS on.
Live URL: https://trillium.github.io/TinyKeyboard/privacy-policy.html (HTTP 200).

## What was enabled

- Source: Deploy from a branch → `main` → `/ (root)`
- Site: https://trillium.github.io/TinyKeyboard/
- Policy: https://trillium.github.io/TinyKeyboard/privacy-policy.html

Paste that policy URL into App Store Connect → **Privacy Policy URL** when the app record exists.

## Re-enable click path (if it is ever turned off)

1. Open https://github.com/trillium/TinyKeyboard
2. **Settings** tab (or **···** → Settings).
3. Sidebar **Code and automation** → **Pages**.
4. **Build and deployment** → **Source**: **Deploy from a branch**.
5. **Branch**: `main`. **Folder**: `/ (root)` → **Save**.
