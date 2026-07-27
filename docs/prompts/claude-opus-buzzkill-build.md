You are Claude Code working inside the Buzzkill repo.

Primary goal:
Build up the repo into the best possible path toward a shippable Buzzkill product, with immediate focus on the iOS app path toward TestFlight, while preserving useful existing work if it helps. You must first decide whether the best route is:
1. continue/fix/refactor the current implementation, or
2. replace/rebuild parts from scratch.

Make that decision based on speed to a working, reviewable, Apple-compliant result.

Important product constraints from the owner:
- The app should work without real APIs first, then note what APIs are needed later.
- Prefer fully functional local fallbacks before real integrations.
- Cost-conscious, practical choices only.
- For iOS, do NOT claim unsupported capabilities like per-app grayscale if they are not actually possible on iOS.
- Frame the iOS app as a mindful interruption / pause tool.
- Keep Android/iOS messaging separated if you touch product copy.

Current known repo context:
- There is existing Android work in /android.
- There is existing web work in /apps/web.
- There is an iOS folder already started with XcodeGen and a SwiftUI scaffold.
- A real Xcode project may already exist or be generatable from ios/project.yml.
- Some app code was already added for demo mode, local protected app selection, simulated interruption shield, local bypass timer, local persistence, and a Screen Time wrapper stub.
- You should inspect the repo yourself and choose whether to keep or replace that work.

Hard requirements for this run:
1. Inspect the repo and explain your decision: fix current work vs rebuild from scratch.
2. Implement the chosen path directly in the repo.
3. Prioritize iOS/TestFlight readiness first.
4. Ensure there is a local demo mode that works without Apple entitlement approval.
5. Keep a real Screen Time / FamilyControls / ManagedSettings / DeviceActivity path abstracted and clearly labeled as entitlement-gated.
6. Generate or maintain a real .xcodeproj in the repo.
7. Attempt local validation/builds where possible.
8. Self-review before stopping:
   - review against Apple/TestFlight/app-copy constraints
   - review against the checklist below
   - fix issues you find if feasible
9. End with a concise report of:
   - what you changed
   - what you decided (fix vs rebuild)
   - what passed locally
   - remaining Apple account / signing / entitlement steps requiring the human

Checklist to satisfy:
# Buzzkill iOS to TestFlight Checklist
- Product definition checklist
  - iOS app messaging does not claim per-app grayscale on iOS.
  - App copy describes the iOS version as an interruption / mindful pause tool.
  - Android and iOS marketing copy are separated.
  - Privacy policy avoids false claims and matches actual behavior.
- Project / build checklist
  - Real .xcodeproj exists in repo.
  - App target builds in Debug on simulator.
  - Bundle identifier is set.
  - Version and build number are set.
  - App icon placeholders exist.
  - Launch/build settings are stable.
- Functional checklist for local fallback mode
  - App launches without entitlement.
  - User can enable demo mode.
  - User can pick from sample social apps locally.
  - User can simulate opening a protected app.
  - App shows a Buzzkill interruption shield/pause screen.
  - User can bypass for a short period.
  - State persists locally across app relaunch.
- Functional checklist for real Screen Time mode
  - FamilyControls imports compile.
  - ManagedSettings imports compile.
  - DeviceActivity imports compile.
  - Code path is isolated behind a service abstraction.
  - App can request FamilyControls authorization when capability is present.
  - App can store selected apps from FamilyActivityPicker.
  - App can describe entitlement requirement when unavailable.
- Signing / Apple checklist
  - Apple Developer team selected in Xcode.
  - Unique bundle ID registered.
  - App capability configuration reviewed.
  - Family Controls entitlement request submitted in Apple Developer portal.
  - TestFlight internal testing group configured.
- Metadata checklist for TestFlight/App Store
  - App name
  - Subtitle
  - Privacy policy URL
  - Support URL
  - App description
  - Keywords
  - Age rating answers
  - Screenshots
  - App icon
  - What to Test note for TestFlight
- Pre-upload checklist
  - Archive succeeds.
  - No placeholder bundle ID remains.
  - No debug-only copy remains in release strings.
  - Demo mode is explained clearly.
  - If Family Controls is not approved yet, real mode UI is clearly labeled unavailable.
  - App Store claims match actual iOS capability.

Execution guidance:
- Use Opus.
- Be proactive.
- If current iOS code is good enough, improve it instead of needless rewrites.
- If it is messy or misleading for App Review, replace it.
- Prefer concrete repo changes over planning text.
- Run builds/checks where possible.
- If a build fails, fix and retry when feasible.
- Do not push git.
- Do not ask the user questions; use best judgment.

When finished, output a concise implementation and review summary.