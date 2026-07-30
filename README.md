# Buzzkill

Less color. More choice.

Buzzkill is a free iPhone app that guides you through a local Apple Shortcuts setup to make selected apps grayscale while they are open, then restore color when they close. It does not block apps, impose time limits, inspect content, or require an account.

[App Store](https://apps.apple.com/app/id6795519571) · [Privacy](docs/PRIVACY.md) · [Support](https://github.com/zyperize/buzzkill/issues) · [Project website](https://zyperize.github.io/buzzkill/)

> The App Store link and project website become live after their respective releases are available. The source repository is the canonical project documentation.

## What is in this repository

- `ios/` — SwiftUI iPhone app and the onboarding flow for the local Shortcuts setup.
- `android/` — separate Kotlin experiment for Android grayscale control; it requires privileged device access and is not the App Store product.
- `apps/web/` — early web prototype and app area.
- `distribution/` — App Store metadata and branded onboarding screenshots.
- `docs/` — product contract, setup guide, privacy policy, and release notes.
- `scripts/` — local development helpers.

The iOS and Android implementations are intentionally separate. They share the product idea and documentation, not application code.

## iOS setup

Requirements:

- macOS with Xcode installed
- XcodeGen if you regenerate the project from `ios/project.yml`
- An iPhone for validating Shortcuts and Color Filters (the simulator cannot verify the complete system automation)

Quick start:

```bash
cd ios
xcodegen generate
open Buzzkill.xcodeproj
```

Select your Apple Developer team in Xcode, then build and run on an iPhone. The full setup checklist is in [docs/SETUP.md](docs/SETUP.md), with iOS-specific behavior documented in [ios/README.md](ios/README.md).

## Product contract

Buzzkill is deliberately a setup guide, not an enforcement tool. The user selects the apps and completes the automation in Apple Shortcuts. See [docs/PRODUCT_CONTRACT.md](docs/PRODUCT_CONTRACT.md) before changing behavior.

## Privacy

The iOS app is designed to work locally with no sign-in, analytics, advertising, tracking, or remote data collection. Read the [privacy policy](docs/PRIVACY.md) and the [App Store release checklist](docs/APP_STORE_RELEASE_READINESS.md).

## Verification

Before submitting an iOS release, validate the physical-device setup flow, shortcut open/close behavior, lock/unlock behavior, and the shipping App Store metadata. The project’s distribution screenshots are the onboarding flow with Buzzkill’s mascot and branding.

## License

No open-source license has been selected yet. Until a license is added, the repository is public for viewing and portfolio purposes, but reuse and redistribution are not automatically granted.
