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

- **iOS:** Apple does not let Buzzkill write the protected Color Filter setting. The app helps the user configure Grayscale once and check whether their iPhone currently exposes the **Set Color Filters** Shortcuts action. When it does, they create two Shortcuts automations: app opened turns it on and app closed turns it off. When it does not, only the manual Accessibility Shortcut is available.
- **Android:** Android can perform the real automatic toggle only after the user grants privileged `WRITE_SECURE_SETTINGS` access. The Android app should write and restore the device-wide grayscale setting directly; it must not copy the iOS Shortcuts flow or use an overlay.

Do not make one platform’s constraints or product copy define the other platform’s implementation.

## Explicit iOS setup UX decision

The owner explicitly chose a hand-held setup instead of a wall of navigation text. The iOS guide must name the exact system paths and the exact `Set Color Filters` action location. Public iOS APIs cannot open the Color Filters pane or the Automations tab directly, so the guide must never claim that a button can land on either exact destination.
