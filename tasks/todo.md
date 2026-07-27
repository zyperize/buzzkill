# Buzzkill Android — real grayscale automation

## Plan

- [x] Remove the existing Android overlay, blocking, bypass, and optional-friction implementation that does not satisfy the grayscale-only product contract.
- [x] Add a small privilege abstraction: standard mode reports that automatic grayscale is unavailable; advanced mode checks for `WRITE_SECURE_SETTINGS` access without pretending it can request the permission normally.
- [x] Add a real grayscale controller that captures the current color-correction state, enables monochrome only when a selected package is foreground, and restores the saved state immediately when it leaves.
- [x] Keep foreground detection local and narrow; it may observe the foreground package but must not inspect screen content or interact with another app.
- [x] Add plain, honest ADB/privileged setup instructions and explain that the automatic build cannot be distributed as an ordinary Play Store app.
- [x] Keep Android code and setup separate from the iOS app; the platforms share only the product contract and documentation.
- [x] Compile the Android app and manually review every product claim against [PRODUCT_CONTRACT.md](../docs/PRODUCT_CONTRACT.md).

## Review

- Android research confirms that real automatic display grayscale requires privileged `WRITE_SECURE_SETTINGS` access. A regular Android app cannot write the required secure display setting.
- The proposed implementation is an advanced, sideloaded/local Android build that obtains this privilege once through ADB, root, or a trusted privileged bridge. It will not use an overlay or block apps.
- The source of truth is now [docs/PRODUCT_CONTRACT.md](../docs/PRODUCT_CONTRACT.md).
- The Android source has been reviewed against that contract: no overlay, blocking, usage limit, Back action, screen-content retrieval, or network operation remains.
- JDK 17 and Android API 35 build tools are installed locally. `:app:compileDebugKotlin` passes.
