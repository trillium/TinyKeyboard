# Captain-only steps — TinyKeyboard 1.0

Only the captain can do these (Apple ID, legal, billing, signing identity, final click). Everything else is already in the repo.
Target: submit by Tuesday 2026-10-20. Each step lists what it unblocks. Order matters.

Team: `85PWBA3B59`. Bundle IDs: `com.trillium.TinyKeyboard`, `com.trillium.TinyKeyboard.keyboard`.

## A. App Store Connect setup (browser, https://appstoreconnect.apple.com)

1. **Agreements, Tax, Banking** — Business > Agreements: accept the Apple Developer Program License Agreement if a banner shows. TinyKeyboard is free, so a Paid Apps agreement, tax and banking are *not* required to ship it. Skip them unless a banner blocks you.
   Unblocks: creating the app record.
2. **Register both App IDs** (only if missing) — developer.apple.com > Certificates, IDs & Profiles > Identifiers: `com.trillium.TinyKeyboard` and `com.trillium.TinyKeyboard.keyboard`. Both are explicit IDs with no capabilities. (Automatic signing in step 6 can create them for you.)
3. **Create the app record** — Apps > + > New App.
   - Platform: iOS. Name: `TinyKeyboard`. Primary language: English (U.S.).
   - Bundle ID: pick `com.trillium.TinyKeyboard`. SKU: `tinykeyboard-ios`. User access: Full Access.
   - If the name `TinyKeyboard` is taken, choose another (for example `TinyKeyboard: Voice Keyboard`) and tell the worker; the subtitle and copy still apply.
   Unblocks: uploading a build, and everything in section C.
4. **Create an API key (for command-line upload)** — Users and Access > Integrations > App Store Connect API > Team Keys > +.
   - Name `tinykeyboard-upload`, access **App Manager**.
   - Download the `.p8` once (Apple will not show it again) and store it at `~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8`.
   - Copy the **Key ID** and the **Issuer ID** (top of the Keys page).
   Skip this step if you upload with Xcode Organizer or Transporter instead (step 7, options B and C).

## B. Signing and the archive

5. **Confirm the archive.** Built 2026-10-16: `build/archive/TinyKeyboard.xcarchive` (under the worktree `/Users/trilliumsmith/.treehouse/TinyKeyboard-20a110/1/TinyKeyboard`; `build/` is gitignored, so rebuild with `scripts/archive-release.sh` on any Mac that has the repo). Version 1.0 (1), iPhone-only, iOS 17.0+, team `85PWBA3B59`.
   Caveat: this archive is **development-signed** (identity `Apple Development: spiteless@gmail.com (TV2582LRYN)`, wildcard dev profile, `get-task-allow = true`). App Store Connect rejects that. It must be re-signed at export (step 6). No Apple Distribution certificate for team `85PWBA3B59` exists on this Mac.
6. **Export with App Store signing.** On a Mac signed in to Xcode with an account on team `85PWBA3B59`:
   ```bash
   xcodebuild -exportArchive \
     -archivePath build/archive/TinyKeyboard.xcarchive \
     -exportOptionsPlist Plans/submission/ExportOptions-AppStore.plist \
     -exportPath build/export \
     -allowProvisioningUpdates
   ```
   Xcode (automatic signing) creates the **Apple Distribution** certificate and two **App Store** profiles (app and extension) on first use. Result: `build/export/TinyKeyboard.ipa`.
   If Xcode says it cannot create the certificate, make one by hand: developer.apple.com > Certificates > + > Apple Distribution, then re-run.
   Check before upload: `codesign -dvv` on the exported app shows `Authority=Apple Distribution: ...` and no `get-task-allow`.

## C. Upload and fill in the record

7. **Upload the build** (pick one; the worker did NOT upload):
   - A. API key (needs step 4): `xcrun altool --upload-app -f build/export/TinyKeyboard.ipa -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>`
   - B. Xcode > Window > Organizer > Archives > select the archive > Distribute App > App Store Connect > Upload.
   - C. Transporter app: drag in `build/export/TinyKeyboard.ipa`.
   Wait for the "build processed" email (5 to 30 minutes). Export compliance should not prompt: `ITSAppUsesNonExemptEncryption = NO` is baked in.
8. **Paste metadata** from `SUBMISSION_PACKAGE.md`: subtitle, promo text, description, keywords, Support URL, Privacy Policy URL, copyright, category Utilities, price Free (Pricing and Availability), age rating 4+.
9. **App Privacy** — App Privacy > Get Started > "No, we do not collect data from this app" > Publish. (Tracking: none.)
10. **Upload screenshots** — iPhone 6.9" display: the four PNGs in `AppStore/screenshots/iphone-6.9/`, in numeric order. There is no iPad section to fill (iPhone-only).
11. **App Review Information** — paste the review notes from `SUBMISSION_PACKAGE.md`; enter your name, phone and email as contact. Sign-in required: off.
12. **Attach the build** — in the version page, Build > + > select 1.0 (1). Choose "Manually release this version" if you want to control the go-live date.

## D. Before the final click

13. **Real-iPhone check (10 minutes)** — run the manual checklist at the bottom of `TESTING.md`, especially step 4 (does the control strip come back after switching away and back?). If it does not, read "Open risk" in `SUBMISSION_PACKAGE.md` and decide: reword the notes or hold for a fix.
14. **Final Submit** — version page > Add for Review > Submit to App Review. Only the captain does this click.

## Decisions already made (change them only if you disagree)

- iPhone-only (`TARGETED_DEVICE_FAMILY = 1`), so no iPad screenshots. Reason: `SPEC.md` lists iPad as a non-goal.
- Free, Utilities, 4+, "Data Not Collected", no Full Access.
- The Xcode project still carries team `TV2582LRYN` for the OTA ad-hoc flow (`ota-publish.sh`). The App Store team `85PWBA3B59` is passed on the command line, so the OTA flow keeps working.
