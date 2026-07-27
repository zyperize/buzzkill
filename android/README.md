# Buzzkill for Android

This is a separate native Kotlin app. It does not copy the iOS Shortcuts flow.

## Android behavior

When a selected package becomes foreground, Buzzkill turns on Android’s real device-wide grayscale setting. When that package closes or another app becomes foreground, Buzzkill restores the user’s prior display-correction state.

Buzzkill must never use an overlay, block access, impose limits, trigger Back actions, or inspect app content.

## Privileged setup

Android reserves the real grayscale setting for privileged secure-settings access. The automatic feature therefore needs one of these setup paths:

1. ADB grant — the reliable baseline for sideloaded builds.
2. Shizuku — an optional convenience path for users who already run it.
3. Root — an advanced fallback.

A normal Play-distributed app cannot request this permission normally. See [../docs/ANDROID_CAPABILITY.md](../docs/ANDROID_CAPABILITY.md) for the complete platform decision.

## Code boundary

All Android-only code, permissions, foreground detection, and secure-settings logic stay in this folder. Do not import or replicate the iOS Color Filters / Shortcuts implementation here.
