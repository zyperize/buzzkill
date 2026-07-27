# Platform resources for Buzzkill

Official docs and policy pages that matter for feasibility and architecture.

## Android

1. Android AccessibilityService API
- URL: https://developer.android.com/reference/android/accessibilityservice/AccessibilityService
- Why it matters: official API surface for observing accessibility events and potentially reacting when target apps are foregrounded.
- Key note captured from docs: "Accessibility services should only be used to assist users with disabilities in using Android devices and apps."

2. Android Accessibility Service guide
- URL: https://developer.android.com/guide/topics/ui/accessibility/service
- Why it matters: implementation guidance, lifecycle, permissions, service metadata, and user enablement flow.

3. Android UsageStatsManager API
- URL: https://developer.android.com/reference/android/app/usage/UsageStatsManager
- Why it matters: alternative foreground-app/usage detection path, useful for feasibility comparison against AccessibilityService.
- Key note captured from docs: "Provides access to device usage history and statistics."

4. Google Play policy: Use of the AccessibilityService API
- URL: https://support.google.com/googleplay/android-developer/answer/10964491?hl=en
- Why it matters: major store-risk document for any Android automation/accessibility-based design.
- Key notes captured from policy:
  - Accessibility-tool claims are restricted.
  - Apps using Accessibility API for automation must have a narrow, clearly understood purpose.
  - Autonomous initiation/planning/execution is prohibited.
  - Deterministic rule-based automation is explicitly called out as allowed.

## Apple / iOS

5. Apple Family Controls
- URL: https://developer.apple.com/documentation/familycontrols
- Why it matters: official entitlement and authorization framework for parental controls / app restriction style products.
- Key notes captured from docs:
  - "Authorize your app to provide parental controls on a device."
  - You must add the Family Controls capability.
  - You must request permission to use the entitlement before App Store submission.

6. Apple Device Activity
- URL: https://developer.apple.com/documentation/deviceactivity
- Why it matters: official monitoring/scheduling layer for app and website activity on iOS.
- Key note captured from docs: privacy-preserving monitoring of app and website activity.

7. Apple Managed Settings
- URL: https://developer.apple.com/documentation/managedsettings
- Why it matters: official API family for restricting/authorizing device behavior and shielding apps with user permission.
- Key note captured from docs: works with Family Controls and Device Activity to restrict, authorize, and monitor device usage.

## Practical takeaway before implementation
- Android likely supports a more direct app-triggered grayscale or intervention flow, but Play policy around AccessibilityService must shape the product carefully.
- iOS likely supports a Screen Time / Family Controls / Managed Settings style intervention model, but not arbitrary system-wide per-app display color control by a third-party app.
- Plan should strongly compare Android-first vs. limited iOS companion/alternative behavior rather than assuming feature parity.
