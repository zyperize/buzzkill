# Buzzkill for iOS

This is a separate native SwiftUI app. It does not use Android privileged settings or an app-blocking API.

## iOS behavior

The user configures the system Color Filter to Grayscale once. Buzzkill installs two signed shortcuts, **Buzzkill On** and **Buzzkill Off**, so the user never has to find or build the Color Filters actions. Buzzkill then runs both shortcuts and verifies that grayscale turns on and color returns. The user creates two Personal Automations and chooses their apps: app opened runs Buzzkill On; app closed runs Buzzkill Off.

Buzzkill only guides that setup. It does not block apps, impose limits, apply shields, or inspect app content.

Setup progress is stored locally. **Start over** clears Buzzkill's local checklist but does not delete shortcuts or automations from Apple's apps.

## Code boundary

All iOS-only SwiftUI code and Apple setup guidance stay in this folder. Do not import or replicate Android secure-settings, ADB, Shizuku, or foreground-service logic here.
