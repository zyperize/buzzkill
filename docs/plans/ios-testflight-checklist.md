# Buzzkill iOS to TestFlight Checklist

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Ship an iOS Buzzkill app that is installable through TestFlight, works in a local demo mode immediately, and can later switch to real FamilyControls / DeviceActivity / ManagedSettings when Apple entitlement approval is ready.

**Architecture:** Build a native SwiftUI app with a runtime-selected intervention engine. Default to a local demo engine that works without Apple approval. Add a real Screen Time engine behind compile/runtime checks so the codebase is ready for entitlement enablement later.

**Tech Stack:** SwiftUI, Swift 6, Xcode 16, XcodeGen, FamilyControls, DeviceActivity, ManagedSettings, UserDefaults/AppStorage.

---

## App Store / TestFlight checklist

### Product definition checklist
- [ ] iOS app messaging does **not** claim per-app grayscale on iOS.
- [ ] App copy describes the iOS version as an interruption / mindful pause tool.
- [ ] Android and iOS marketing copy are separated.
- [ ] Privacy policy avoids false claims and matches actual behavior.

### Project / build checklist
- [ ] Real `.xcodeproj` exists in repo.
- [ ] App target builds in Debug on simulator.
- [ ] Bundle identifier is set.
- [ ] Version and build number are set.
- [ ] App icon placeholders exist.
- [ ] Launch/build settings are stable.

### Functional checklist for local fallback mode
- [ ] App launches without entitlement.
- [ ] User can enable demo mode.
- [ ] User can pick from sample social apps locally.
- [ ] User can simulate opening a protected app.
- [ ] App shows a Buzzkill interruption shield/pause screen.
- [ ] User can bypass for a short period.
- [ ] State persists locally across app relaunch.

### Functional checklist for real Screen Time mode
- [ ] `FamilyControls` imports compile.
- [ ] `ManagedSettings` imports compile.
- [ ] `DeviceActivity` imports compile.
- [ ] Code path is isolated behind a service abstraction.
- [ ] App can request FamilyControls authorization when capability is present.
- [ ] App can store selected apps from `FamilyActivityPicker`.
- [ ] App can describe entitlement requirement when unavailable.

### Signing / Apple checklist
- [ ] Apple Developer team selected in Xcode.
- [ ] Unique bundle ID registered.
- [ ] App capability configuration reviewed.
- [ ] Family Controls entitlement request submitted in Apple Developer portal.
- [ ] TestFlight internal testing group configured.

### Metadata checklist for TestFlight/App Store
- [ ] App name
- [ ] Subtitle
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] App description
- [ ] Keywords
- [ ] Age rating answers
- [ ] Screenshots
- [ ] App icon
- [ ] What to Test note for TestFlight

### Pre-upload checklist
- [ ] Archive succeeds.
- [ ] No placeholder bundle ID remains.
- [ ] No debug-only copy remains in release strings.
- [ ] Demo mode is explained clearly.
- [ ] If Family Controls is not approved yet, real mode UI is clearly labeled unavailable.
- [ ] App Store claims match actual iOS capability.

### Immediate next build steps
- [ ] Create iOS app project.
- [ ] Build demo-mode intervention flow first.
- [ ] Add real Screen Time service wrapper second.
- [ ] Add onboarding and settings.
- [ ] Build on simulator.
- [ ] Prepare signing/TestFlight metadata.
