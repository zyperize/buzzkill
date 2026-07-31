# Buzzkill — App Store release readiness

_Checked July 31, 2026._

## Complete in the project

- [ ] Re-run the iOS build and launch after the release changes; this environment currently lacks an available CoreSimulator runtime.
- [x] Bundle identifier is `com.buzzkill.app`.
- [x] Source version is `1.0` (`1`); the currently attached ASC build predates this change and must be rebuilt before submission.
- [x] Privacy manifest is bundled. It declares local-only `UserDefaults` storage with Apple’s `CA92.1` reason.
- [x] No analytics, advertising, tracking, sign-in, payments, networking, or ATT code is present in the iOS target.
- [x] The privacy-policy draft now describes the actual iOS behavior: local setup storage only; no app blocking, usage tracking, or data uploads.

## Must be completed in Apple accounts before TestFlight or App Store submission

- [ ] In **Xcode → Buzzkill target → Signing & Capabilities**, select the Apple Developer team for the Apple ID you added. Xcode then creates or downloads the matching provisioning profile.
- [ ] In the Apple Developer account, register `com.buzzkill.app` if it does not already exist.
- [ ] Install both bundled shortcuts on a physical iPhone and validate the opened/closed automations.
- [ ] Run the setup-flow regression on a physical iPhone:
  - Buzzkill On must stop on **Did the colors turn gray?** indefinitely.
  - **Yes, it turned gray — Continue** must run Buzzkill Off before advancing.
  - **No, I still see color** must run Buzzkill Off before showing the repair guide.
  - Back or Close from the gray confirmation must restore color without marking the test verified.
  - Every setup page after the first must expose Back; every completed action must expose a clearly labeled Next or Finish action.
  - **Open Accessibility** must be tested on the shipping iOS version; if its private route fails, the main-Settings fallback and pictured guide must remain usable.
- [ ] Resolve the lock/unlock bypass before release: locking a selected app can fire its close rule, while unlocking into that still-frontmost app may not fire its open rule. Validate the proposed app-scheduled Focus strategy on a physical iPhone.
- [ ] Before App Store submission, review the onboarding's undocumented `App-Prefs:` Accessibility-root link and main-Settings fallback. Apple provides no public Accessibility URL and may reject private URL schemes.
- [x] Create or sign into a dedicated App Store Connect CLI profile for Buzzkill (local profile is configured; private key is kept outside the repo).
- [x] Create the Buzzkill app record in App Store Connect after the bundle ID exists.
- [x] GitHub Pages privacy/support URLs verified anonymously and entered in App Store Connect.
- [ ] Set App Privacy in App Store Connect to **Data Not Collected**, provided the shipping binary remains local-only.
- [x] Upload six validated iPhone screenshots covering the onboarding and the color-to-grayscale concept. Do not claim that Buzzkill itself applies grayscale or auto-creates automations.
- [x] Add App Review notes explaining: “Buzzkill guides users through a local Apple Shortcuts setup. It does not block apps, monitor use, or change Color Filters directly. The user selects apps and completes any automation in Shortcuts.”
- [ ] Archive, upload to TestFlight, and test this flow on a physical iPhone before submission.

## Current release blocker

The local source still needs physical-device Shortcuts verification, signing, and a shipping build/test pass. iOS does not expose a public unlock automation trigger, so the setup guide documents the lock/unlock limitation and the reliable recovery step: briefly switch away and reopen the selected app.
