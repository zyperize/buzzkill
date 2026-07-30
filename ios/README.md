# Buzzkill for iOS

This is a separate native SwiftUI app. It does not use Android privileged settings or an app-blocking API.

## iOS behavior

Buzzkill installs two signed shortcuts, **Buzzkill On** and **Buzzkill Off**, so the user never has to find or build the Color Filters actions. Buzzkill On leaves a visible rainbow test target on screen until the user explicitly confirms whether it turned gray. Either answer runs Buzzkill Off first: success advances to automation setup, while visible color opens the illustrated Color Filters repair. The user then creates two Personal Automations and chooses their apps: app opened runs Buzzkill On; app closed runs Buzzkill Off.

Buzzkill only guides that setup. It does not block apps, impose limits, apply shields, or inspect app content.

Setup progress is stored locally. **Start over** clears Buzzkill's local checklist but does not delete shortcuts or automations from Apple's apps.

Apple provides no public deep link to Accessibility or Color Filters. The conditional repair tries an Accessibility-root route that is separate from the route observed misrouting to app settings, falls back to main Settings, and explains how to return to main Settings if needed. A compact button opens a swipeable five-page tutorial of generated Apple-style tap illustrations. The Personal Automation step includes privacy-safe screenshots captured from iOS Simulator and detailed instructions for the exact Shortcuts controls.

The current App close trigger has a release-blocking lock/unlock edge case: locking can run Buzzkill Off, but unlocking into the still-frontmost selected app may not run Buzzkill On. An app-scheduled custom Focus driving the same On/Off shortcuts is the leading replacement, pending physical-device validation.

## Code boundary

All iOS-only SwiftUI code and Apple setup guidance stay in this folder. Do not import or replicate Android secure-settings, ADB, Shizuku, or foreground-service logic here.
