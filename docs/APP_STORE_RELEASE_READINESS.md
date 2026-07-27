# Buzzkill — App Store release readiness

_Checked July 27, 2026._

## Complete in the project

- [x] Re-run the iOS Simulator build and launch after the grayscale-automation update.
- [x] Bundle identifier is `com.buzzkill.app`.
- [x] Version is `0.1.0` (`1`).
- [x] Privacy manifest is bundled. It declares local-only `UserDefaults` storage with Apple’s `CA92.1` reason.
- [x] No analytics, advertising, tracking, sign-in, payments, networking, or ATT code is present in the iOS target.
- [x] The privacy-policy draft now describes the actual iOS behavior: local setup storage only; no app blocking, usage tracking, or data uploads.

## Must be completed in Apple accounts before TestFlight or App Store submission

- [ ] In **Xcode → Buzzkill target → Signing & Capabilities**, select the Apple Developer team for the Apple ID you added. Xcode then creates or downloads the matching provisioning profile.
- [ ] In the Apple Developer account, register `com.buzzkill.app` if it does not already exist.
- [ ] Install both bundled shortcuts on a physical iPhone and validate the opened/closed automations.
- [ ] Before App Store submission, review the onboarding's undocumented `App-Prefs:` link. It currently opens the top-level Settings app for a shorter setup flow, but Apple provides no public API for this destination and may reject private URL schemes. The UI must never claim that it opens Color Filters directly.
- [ ] Create or sign into a dedicated App Store Connect CLI profile for Buzzkill (or use Xcode Organizer). No local App Store Connect credentials are configured for Buzzkill yet.
- [ ] Create the Buzzkill app record in App Store Connect after the bundle ID exists.
- [ ] Publish `docs/PRIVACY.md` at a public HTTPS URL, replace its Contact placeholder with a real support email or support page, and enter that URL in App Store Connect. Also enter a Support URL.
- [ ] Set App Privacy in App Store Connect to **Data Not Collected**, provided the shipping binary remains local-only.
- [ ] Capture store screenshots from the final binary, including shortcut installation and Personal Automation setup. Do not claim that Buzzkill itself applies grayscale or auto-creates automations.
- [ ] Add App Review notes explaining: “Buzzkill guides users through a local Apple Shortcuts setup. It does not block apps, monitor use, or change Color Filters directly. The user selects apps and completes any automation in Shortcuts.”
- [ ] Archive, upload to TestFlight, and test this flow on a physical iPhone before submission.

## Current release blocker

The local source is **not submission-ready yet** because physical-device Shortcuts verification, signing, App Store Connect credentials, and a published privacy/support URL still require the account owner. These are account and hosting steps rather than code defects.
