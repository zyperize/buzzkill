# Optional Speed Bumps + Better Moves Implementation Plan

> **For Opus:** implement only after reviewing current Buzzkill web/iOS/Android changes. Keep everything local-first; no real API dependency. Android compile may remain blocked by missing Java on this machine.

**Goal:** Add two optional behavior layers on top of Buzzkill's app grayscale/intervention flow: an escalating friction system and a replacement-action prompt system.

**Feature names:**
- **Speed Bumps** — optional escalating friction ladder that interrupts autopilot without fully removing user choice.
- **Better Moves** — optional replacement-action menu that asks what the user would rather do and shows category-specific encouraging copy.

**Product principle:** Buzzkill should feel like a dopamine governor, not a parental-control jail. The user can turn each feature on/off independently.

**Tech stack / target files:**
- Web landing/demo: `apps/web/src/app/page.tsx`
- iOS: `ios/Buzzkill/Views/ContentView.swift`, `ios/Buzzkill/ViewModels/AppViewModel.swift`, intervention/shield models/views if needed
- Android: `android/app/src/main/java/com/buzzkill/MainActivity.kt`, `android/app/src/main/java/com/buzzkill/data/SettingsRepository.kt`, `android/app/src/main/java/com/buzzkill/overlay/OverlayManager.kt`, `android/app/src/main/java/com/buzzkill/core/InterventionDecider.kt`

---

## Product Definition

### 1. Speed Bumps

Optional toggle: **Speed Bumps**

Purpose: escalate friction when the user repeatedly opens or stays inside a protected app.

Suggested ladder:
1. **Glance** — grayscale/dim only; low interruption.
2. **Pause** — short forced pause before bypass, e.g. 10 seconds.
3. **Name it** — ask the user to choose why they are opening the app: `Work`, `Message someone`, `Entertainment`, `I don't know`.
4. **Intent phrase** — require a short typed confirmation such as: `I choose this intentionally`.
5. **Cooldown** — if repeated bypasses continue, suggest or apply a short cooldown.

MVP implementation can be simpler:
- Persist `speedBumpsEnabled: Boolean`
- Track local/session bypass count per protected app or globally
- Map bypass count to an intensity label/message
- No cloud/account required

Copy examples:
- `Speed bump 1: Make it intentional.`
- `Still want this? Take 10 seconds first.`
- `Name the reason before you continue.`
- `Autopilot detected. Choose intentionally or take a better move.`
- `This is your third bypass. Future-you probably wants a pause.`

### 2. Better Moves

Optional toggle: **Better Moves**

Prompt wording:
- Main question: **What would you rather do right now?**
- Supporting line: `Pick a better move, or continue intentionally.`

Suggested categories and message groups:

#### Move your body
Actions:
- `10 pushups`
- `2-minute walk`
- `Stretch your neck`
- `Drink water`
Messages:
- `Move first. Scroll after if you still care.`
- `Your body gets the first vote.`
- `Two minutes beats twenty lost minutes.`
- `Change your state before changing apps.`

#### Read / learn
Actions:
- `Read 2 pages`
- `Open Kindle`
- `Read saved article`
- `Learn one thing`
Messages:
- `Trade the feed for one useful page.`
- `A small read counts.`
- `Make boredom productive for two minutes.`
- `Feed your brain, not the algorithm.`

#### Text someone / social for real
Actions:
- `Text a friend`
- `Call family`
- `Send a voice note`
- `Reply to one real person`
Messages:
- `Real people beat infinite feeds.`
- `Use your phone to connect, not drift.`
- `One real message is better than 50 fake updates.`
- `Social media is not the only social option.`

#### Work on your business
Actions:
- `Write one idea`
- `Send one outreach message`
- `Review today's numbers`
- `Do a 5-minute task`
Messages:
- `Build the thing that buys your freedom.`
- `One business move before one dopamine hit.`
- `Do the tiny revenue action first.`
- `Your future business needs this minute.`

#### Clean up / life admin
Actions:
- `Clear 5 emails`
- `Tidy one surface`
- `Pay/check one bill`
- `Plan tomorrow`
Messages:
- `Make life lighter by one small task.`
- `One boring win now, less stress later.`
- `Close a loop before opening a feed.`
- `Small admin beats big regret.`

#### Calm down
Actions:
- `30-second breathing`
- `Sit with no phone`
- `Write one sentence`
- `Play one song without scrolling`
Messages:
- `Maybe you need a reset, not an app.`
- `Let the urge pass before you obey it.`
- `Breathe first. Decide second.`
- `You are allowed to do nothing.`

MVP behavior:
- Persist `betterMovesEnabled: Boolean`
- Store a static local list of categories/actions/messages
- On overlay/shield, show 3-6 category chips or cards when enabled
- Selecting a category shows one rotating message from that category and a tiny completion prompt such as `Done` / `Open anyway`
- Keep `Open anyway` available, but less prominent than the better move.

---

## Implementation Tasks

### Task 1: Add settings data fields

**Objective:** Persist independent toggles for Speed Bumps and Better Moves.

**Files:**
- Modify: `ios/Buzzkill/ViewModels/AppViewModel.swift`
- Modify: `android/app/src/main/java/com/buzzkill/data/SettingsRepository.kt`

**Steps:**
1. Add `speedBumpsEnabled` default `true` or `false`? Use `false` if conservative; Opus may choose `true` for demo visibility but UI must allow off.
2. Add `betterMovesEnabled` default `true` for demo value, but still user-toggleable.
3. Persist both locally alongside existing protected apps / focus intensity.
4. Verify app state survives reload/relaunch where feasible.

### Task 2: Add UI toggles in main settings screens

**Objective:** Let users turn each option on/off independently.

**Files:**
- Modify: `ios/Buzzkill/Views/ContentView.swift`
- Modify: `android/app/src/main/java/com/buzzkill/MainActivity.kt`

**UI copy:**
- `Speed Bumps`
- `Escalate from grayscale to short pauses when you keep coming back.`
- `Better Moves`
- `Ask what you'd rather do: exercise, read, text someone, work on your business, or reset.`

**Steps:**
1. Add two cards/toggles near Focus intensity.
2. Use the same monochrome/minimal design language.
3. Keep toggles visually independent.
4. Do not overcrowd the screen; concise copy.

### Task 3: Model Better Moves locally

**Objective:** Create local data structures for replacement categories, actions, and messages.

**Files:**
- iOS: create or inline a simple model if small, e.g. `BetterMoveCategory` in `ContentView.swift` or a new model file.
- Android: add simple data class/list near overlay/UI code or in a small model file.

**Categories:**
- Move your body
- Read / learn
- Text someone
- Work on your business
- Clean up / life admin
- Calm down

**Steps:**
1. Add static category data.
2. Include 2-4 actions per category for MVP.
3. Include 3-4 messages per category.
4. Deterministic or random rotation is okay; keep it local.

### Task 4: Add Better Moves to shield/overlay flow

**Objective:** When Better Moves is enabled, protected-app interruption asks: `What would you rather do right now?`

**Files:**
- iOS: `ios/Buzzkill/Views/ShieldView.swift` and/or demo screen if current shield is not wired locally.
- Android: `android/app/src/main/java/com/buzzkill/overlay/OverlayManager.kt`

**Behavior:**
1. Show question: `What would you rather do right now?`
2. Show category chips/cards.
3. On selection, show category-specific message and simple actions.
4. Keep a smaller `Continue anyway` or `Bypass` option.
5. If Better Moves is off, current overlay remains unchanged.

### Task 5: Add Speed Bumps to intervention copy/logic

**Objective:** If Speed Bumps is enabled, repeated bypass/open attempts become more intentional.

**Files:**
- iOS: `ios/Buzzkill/Services/InterventionEngine.swift`, `ios/Buzzkill/Services/DemoInterventionEngine.swift`, `ios/Buzzkill/Models/ShieldState.swift`, `ios/Buzzkill/Views/ShieldView.swift` as appropriate.
- Android: `android/app/src/main/java/com/buzzkill/core/InterventionDecider.kt`, `android/app/src/main/java/com/buzzkill/overlay/OverlayManager.kt`.

**MVP behavior:**
1. Track local bypass/open attempt count in memory or persisted lightweight state.
2. Map attempt count to message:
   - 1: `Make it intentional.`
   - 2: `Take 10 seconds first.`
   - 3: `Name the reason before you continue.`
   - 4+: `Autopilot detected. Choose a better move or continue intentionally.`
3. If toggle is off, preserve current behavior.

**Do not overbuild:** no accounts, streaks, AI, cloud, analytics, push notifications, or real Screen Time dependency changes.

### Task 6: Update web landing/demo to show the two optional features

**Objective:** Make the landing page explain and demo Speed Bumps + Better Moves.

**Files:**
- Modify: `apps/web/src/app/page.tsx`

**Content to add:**
- Settings mockup rows:
  - `Speed Bumps: Optional`
  - `Better Moves: Optional`
- Feature section cards:
  - `Speed Bumps` — `Grayscale first. Then short pauses, intent prompts, and cooldowns if you keep coming back.`
  - `Better Moves` — `When you open a protected app, Buzzkill asks what you'd rather do: move, read, text someone, build your business, clean up, or calm down.`

### Task 7: Verification

**Run feasible checks:**
- Web: from `apps/web`, run `npm run lint` and `npm run build`.
- iOS: run the same simulator build command previously used if available in shell history/docs, or at minimum validate Swift syntax/build with xcodebuild if installed.
- Android: attempt the normal Gradle compile only if Java exists. If Java is missing, report: `Android compile blocked by missing Java runtime on this machine`.

**Acceptance criteria:**
- Both features are toggleable/off independently.
- App still works with both disabled.
- No real API dependencies.
- Web build/lint pass.
- iOS build still passes if environment allows.
- Android status is accurately reported, not hidden.

---

## Final response requested from Opus

Return concise bullets:
- What changed
- Files touched
- Verification passed
- Verification blocked
- Any product/design note worth Mark seeing
