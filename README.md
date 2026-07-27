# Buzzkill

Buzzkill has two native implementations of the same grayscale-only product outcome.

## Goal
Make selected apps black and white while they are open, then restore color when they close—without blocking, limiting, overlaying, or inspecting another app.

## Current status
- Repo initialized
- Working name chosen: Buzzkill
- iOS Shortcuts and Color Filters setup implemented under `ios/`
- Android direct secure-settings implementation planned under `android/`
- No app blocking or time-limit behavior
- The two platforms deliberately use different code and setup paths

## Repo structure
- `ios/` — SwiftUI app; guides the one-time Apple Shortcuts / Color Filters setup
- `android/` — Kotlin app; directly controls Android grayscale only after privileged secure-settings access
- `apps/web/` — existing web prototype/app area
- `docs/` — shared product contracts and platform-specific capability notes
- `scripts/` — local helper scripts

Shared code is intentionally not used. The platforms share only the product contract in [docs/PRODUCT_CONTRACT.md](docs/PRODUCT_CONTRACT.md).
