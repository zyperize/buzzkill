# Buzzkill product contract

## The one non-negotiable behavior

Buzzkill is **not** an app blocker, app limiter, Screen Time shield, or parental-control product.

When the user opens an app they selected, Buzzkill’s intended behavior is to turn the **entire iPhone display** black and white by enabling the user-configured system Grayscale Color Filter. When the user closes that selected app, it turns the Color Filter back off and restores color.

The user can still open and use every selected app normally. Buzzkill changes only the display color while that app is open.

## Product boundaries

- Do not use `ManagedSettings` shields, Family Controls restrictions, app blocking, time limits, cooldowns, or bypass timers for the core product.
- Do not describe Buzzkill as a mindful-pause, interruption, Screen Time, or parental-control app.
- Do not claim Buzzkill can recolor an individual app’s pixels. The effect is a system-wide Color Filter, toggled by an app-open/app-close automation.
- Keep setup as short and clear as the platform allows. On iOS, the user must configure the system Grayscale filter once and create the app-triggered Shortcuts automation because third-party apps cannot directly change that protected setting.

## Implementation decision rule

If a proposed feature blocks access, tracks duration, applies a shield, or changes what the user can do inside another app, it is not Buzzkill and must not be implemented without explicit owner approval.

## Platform implementations are intentionally different

The iOS and Android apps share the grayscale-only outcome, not the same technical implementation or setup flow.

- **iOS:** Apple does not let Buzzkill write the protected Color Filter setting or create Personal Automations. Buzzkill bundles two Apple-signed shortcuts, **Buzzkill On** and **Buzzkill Off**, which the user installs from onboarding. The user creates two Personal Automations and chooses their apps: app opened runs Buzzkill On; app closed runs Buzzkill Off.
- **iOS verification:** Before asking the user to build automations, onboarding runs Buzzkill On and waits indefinitely for the user to inspect a visible rainbow test target. **Yes, it turned gray** runs Buzzkill Off, verifies that normal color returned, and advances. **No, I still see color** runs Buzzkill Off before showing the one-time Color Filters repair guide.
- **Android:** Android can perform the real automatic toggle only after the user grants privileged `WRITE_SECURE_SETTINGS` access. The Android app should write and restore the device-wide grayscale setting directly; it must not copy the iOS Shortcuts flow or use an overlay.

Do not make one platform’s constraints or product copy define the other platform’s implementation.

## Explicit iOS setup UX decision

The owner explicitly chose a hand-held setup instead of a wall of navigation text. Buzzkill installs signed On/Off shortcuts so users never build the Color Filters actions themselves. Setup progress persists locally and can be reset from the main screen. Public iOS APIs cannot open the Color Filters pane, create a Personal Automation, select apps, or force the Automations tab, so the guide must clearly coach those remaining system-owned steps.

The Grayscale repair provides an **Open Accessibility** button. The route that was observed misrouting to Buzzkill's app-settings page is not used; the app tries the older Accessibility-root route first and falls back to main Settings. Because all system-page routes are undocumented, the UI explicitly explains how to return to the main Settings screen if needed. A compact **View tap-by-tap guide** button opens a dedicated five-page visual tutorial with one Apple-style image and one arrow per tap: Accessibility → Display & Text Size → Color Filters → enable Color Filters → Grayscale. The repair appears only after the user explicitly reports that the visual test still shows color, and Buzzkill Off restores normal color before the repair screen appears.

## Known iOS lock/unlock trigger defect

The App “Is Closed” automation may fire when the phone locks, turning Color Filters off. Unlocking directly back into the same app may not fire “Is Opened,” leaving that app in color. Buzzkill must not describe the current App-open/App-close strategy as lock-safe until this is resolved.

The leading replacement candidate is an app-scheduled custom Focus named Buzzkill, with Focus-on and Focus-off Personal Automations running the existing Buzzkill On/Off shortcuts. Apple documents both app-based Focus schedules and Focus automation triggers, but this exact lock/unlock sequence still requires physical-device validation before it replaces the simpler setup.
