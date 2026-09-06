# Privacy policy — public URL (needs a repo-settings click)

The static page is already in the repo:

- File: [`privacy-policy.html`](../privacy-policy.html) (repo root)
- Intended public URL after GitHub Pages is enabled:
  `https://trillium.github.io/TinyKeyboard/privacy-policy.html`

App Store Connect requires a **public** privacy-policy URL. The in-app `PrivacyPolicyView` does not satisfy that. Tailscale OTA (`tailscale serve`) is tailnet-only and does not qualify.

GitHub Pages is **not enabled** on `trillium/TinyKeyboard` (Pages API 404 as of 2026-09-06). Enabling it is a repository Settings change. This session did **not** flip that switch.

## Exact click path (do this, then stop)

1. Open https://github.com/trillium/TinyKeyboard
2. Click the **Settings** tab under the repo name.
   If the tab is hidden: click the **···** button → **Settings**.
3. In the left sidebar, under **Code and automation**, click **Pages**.
4. Under **Build and deployment** → **Source**, choose **Deploy from a branch**.
5. **Branch**: `main`. **Folder**: `/ (root)`.
6. Click **Save**.
7. Wait until the Pages site shows as live (green check). The site root will be
   `https://trillium.github.io/TinyKeyboard/`.
8. Confirm the policy loads:
   `https://trillium.github.io/TinyKeyboard/privacy-policy.html`
9. Paste that URL into App Store Connect → the app's **Privacy Policy URL** field.

Do not use a `gh-pages` branch or GitHub Actions unless you specifically want those; the root-of-`main` source is enough because `privacy-policy.html` already lives at the repo root.

## After Pages is live

- App Store Connect metadata: Privacy Policy URL = `https://trillium.github.io/TinyKeyboard/privacy-policy.html`
- Optional: set the GitHub repo **Website** field to the same URL (repo Settings → General → Website).
