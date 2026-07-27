# Android capability decision

## Product requirement

When a selected app opens, turn the **device-wide Android grayscale display mode** on. When it closes, turn grayscale off. Do not overlay, block, shield, limit, or replace the selected app.

## Platform fact

Android stores display accessibility settings in `Settings.Secure`. Normal third-party apps can read these settings but cannot write them. The permission required to write them, `WRITE_SECURE_SETTINGS`, is not available to ordinary third-party apps.

The implementation uses Android Open Source Project’s `accessibility_display_daltonizer_enabled` setting with monochromacy mode `0`; AOSP maps that mode to the device-wide grayscale color transform. OEM Android builds should still be tested on a physical device.

That means a normal Play-distributed Android app cannot automatically toggle the real grayscale display mode on an app-open event.

## Viable Android build

Build the real grayscale automation as an advanced, locally installed mode:

1. The user grants Buzzkill `WRITE_SECURE_SETTINGS` once. Support ADB as the reliable baseline; optionally support Shizuku as an on-device convenience path for users who already run it. Root is an advanced fallback.
2. Buzzkill observes foreground-app changes with the narrowest available local detector.
3. When a selected package becomes foreground, Buzzkill writes the real Android grayscale settings.
4. When any other app becomes foreground, Buzzkill restores the prior color-correction state.

The app must capture and restore the user’s existing display-correction configuration. It must never leave a device grayscale by accident.

### ADB setup

Enable Developer options and USB debugging, connect the device to a computer with Android platform-tools installed, then run:

```bash
adb shell pm grant com.buzzkill android.permission.WRITE_SECURE_SETTINGS
```

Buzzkill verifies the grant before its Automatic grayscale switch can be enabled. Disabling its accessibility service restores the display setting it captured before the selected app opened, provided the grant remains available. Turn off Automatic grayscale before revoking the grant; after revocation Android will not permit Buzzkill to restore the display setting.

## Explicitly rejected

- A dim or grayscale-looking overlay: it does not make the other app black and white.
- Accessibility-driven app blocking or global Back actions.
- Usage limits, shields, cooldowns, and bypass timers.
- A Play Store claim that ordinary permissions enable automatic grayscale.

## Distribution consequence

The automatic Android version is best treated as a sideloaded advanced build unless a device-management distribution channel supplies the required privileged permission. A standard Play build can provide only manual guidance, not the core automatic behavior.

## Sources

- [Android Settings.Secure](https://developer.android.com/reference/android/provider/Settings.Secure.html): normal applications cannot write secure settings.
- [Android WRITE_SECURE_SETTINGS](https://developer.android.com/reference/android/Manifest.permission): not for third-party applications.
- [AOSP Settings source](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android10-dev/core/java/android/provider/Settings.java): the daltonizer secure-setting keys and monochromacy mode.
