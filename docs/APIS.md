# Buzzkill — distribution requirements

Buzzkill has no backend, paid API, analytics SDK, login, or cloud account.

## iOS

To distribute the iOS guide app, the only required account is the [Apple Developer Program](https://developer.apple.com/programs/enroll/) ($99/year). The app does not need the Family Controls entitlement because app selection happens in Shortcuts, not in Buzzkill.

Before release, test on a real iPhone whether Shortcuts exposes **Set Color Filters**. If it does, automatic setup can use two personal automations: app opened turns the filter on and app closed turns it off. If it does not, the app must present the manual Accessibility Shortcut fallback. Buzzkill cannot change the protected setting itself.

## Android

The real automatic Android build requires `WRITE_SECURE_SETTINGS`, a privileged permission that normal Play Store apps cannot receive. The implementation is therefore intended for sideloaded/internal distribution, with a one-time ADB grant:

```bash
adb shell pm grant com.buzzkill android.permission.WRITE_SECURE_SETTINGS
```

It also asks the user to enable its narrowly scoped AccessibilityService so it can react to foreground-app changes. The service does not retrieve screen content, take actions inside other apps, block anything, or draw an overlay.

See [ANDROID_CAPABILITY.md](./ANDROID_CAPABILITY.md) for the platform constraint and exact setup.

## Still needed before a release

- An Apple Developer membership and App Store Connect record for iOS distribution.
- A physical iPhone test of the current Shortcuts action availability.
- A JDK 17 + Android SDK environment and physical Android-device test for the privileged build.
- A hosted version of [PRIVACY.md](./PRIVACY.md) with a real support contact.
