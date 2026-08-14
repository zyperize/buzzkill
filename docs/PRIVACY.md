# Buzzkill — Privacy Policy

The canonical, published privacy policy for Buzzkill lives at:

**https://zyperize.github.io/buzzkill/privacy.html**

That URL is the one filed in App Store Connect. It is the single source of
truth, and it is served from [`docs/site/privacy.html`](site/privacy.html).

This file used to hold a second copy of the policy. It is now a pointer instead,
so that there is never more than one published version of the policy in
circulation. Edit `docs/site/privacy.html` to change the policy.

## Short version

Buzzkill does not collect, transmit, store on a remote server, or share personal
data. It stores local setup state (whether each bundled shortcut installer was
opened, whether the local shortcut test passed, whether setup was marked
finished) in `UserDefaults` on the device, and reads whether the system
grayscale setting is enabled so it can show setup status. Deleting the app
removes all of it.

No analytics, crash reporting, advertising, third-party identifiers, background
uploads, app blocking, usage monitoring, screen-content access, location,
microphone, camera, or contacts access.

See also the [terms of use](site/terms.html).
