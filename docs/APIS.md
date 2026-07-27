# Buzzkill — distribution requirements

Buzzkill has no backend, paid API, analytics SDK, login, or cloud account.

## iOS

To distribute the iOS guide app, the only required account is the [Apple Developer Program](https://developer.apple.com/programs/enroll/) ($99/year). The app does not need the Family Controls entitlement because app selection happens in Shortcuts, not in Buzzkill.

Buzzkill bundles two shortcuts signed by Apple for installation by any user. Before release, test both bundled `.shortcut` installers and both Personal Automations on a physical iPhone. Buzzkill cannot change the protected setting or create Personal Automations itself.

## Android

The real automatic Android build requires `WRITE_SECURE_SETTINGS`, a privileged permission that normal Play Store apps cannot receive. The implementation is therefore intended for sideloaded/internal distribution, with a one-time ADB grant:

```bash
adb shell pm grant com.buzzkill android.permission.WRITE_SECURE_SETTINGS
```

It also asks the user to enable its narrowly scoped AccessibilityService so it can react to foreground-app changes. The service does not retrieve screen content, take actions inside other apps, block anything, or draw an overlay.

See [ANDROID_CAPABILITY.md](./ANDROID_CAPABILITY.md) for the platform constraint and exact setup.

## Still needed before a release

- An Apple Developer membership and App Store Connect record for iOS distribution.
- A physical iPhone test of both shortcut installers and both automations.
- A JDK 17 + Android SDK environment and physical Android-device test for the privileged build.
- A hosted version of [PRIVACY.md](./PRIVACY.md) with a real support contact.
