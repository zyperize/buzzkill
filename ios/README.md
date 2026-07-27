# Buzzkill for iOS

This is a separate native SwiftUI app. It does not use Android privileged settings or an app-blocking API.

## iOS behavior

The user chooses their apps and configures the system Color Filter to Grayscale once. Buzzkill then has them check whether their iPhone exposes **Set Color Filters** in Shortcuts. If it does, they create two Personal Automations: app opened turns Color Filters on; app closed turns them off. If that action is missing, automatic per-app grayscale is unavailable and Buzzkill guides the manual Accessibility Shortcut instead.

Buzzkill only guides that setup. It does not block apps, impose limits, apply shields, or inspect app content.

## Code boundary

All iOS-only SwiftUI code and Apple setup guidance stay in this folder. Do not import or replicate Android secure-settings, ADB, Shizuku, or foreground-service logic here.
