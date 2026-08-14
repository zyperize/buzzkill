# Buzzkill — pre-launch security, privacy, and legal audit (2026-08-14)

Read-only audit of the whole repo before the iOS App Store launch. No code
changed yet. Findings below, then the proposed fix plan awaiting approval.

## What is clean

- No networking, no third-party SDKs, no analytics, ads, tracking, accounts,
  payments, or ATT anywhere in the iOS target.
- Empty entitlements, no ATS exceptions, `ITSAppUsesNonExemptEncryption` false.
- `PrivacyInfo.xcprivacy` declares only `UserDefaults` (CA92.1), which matches
  the code. "Data Not Collected" is the correct App Privacy answer.
- No secrets committed, in the working tree or anywhere in git history.
  `.asc/config.json` and `apps/web/.vercel/` are gitignored and untracked.
- Bundled shortcuts are properly Apple-signed (AEA1). Their certificate chains
  carry opaque random CNs, so no Apple ID or personal identity leaks.
- The `--onboarding-page` launch argument is `#if DEBUG` gated and absent from
  release builds, so it is not a hidden feature under guideline 2.3.1.

## Findings

### Blockers before submission

- [ ] B1. `apps/web` runs Next.js 16.2.6 with four high-severity advisories
  (image-optimization DoS, unauthenticated disclosure of internal Server
  Function endpoints, postcss path traversal, sharp/libvips CVEs). This is the
  only internet-facing code in the repo. Upgrade, or take the Vercel
  deployment down since the shipping app links to GitHub Pages instead.
- [ ] B2. Two different privacy policies are published: GitHub Pages
  (`docs/site/privacy.html`, "July 26") and the Vercel Next site
  (`apps/web/src/app/privacy/page.tsx`, "July 30"), with different wording.
  Conflicting published policies are a real legal exposure. Keep exactly one
  canonical policy; App Store metadata points at the GitHub Pages URL.
- [ ] B3. The hosted privacy policy has no data-controller identity and no
  email contact. GDPR Art. 13 requires both; a GitHub issues link alone is not
  a controller identity. Add a legal/DBA name and a real contact email.

### Legal gaps worth closing (cheap, low effort)

- [ ] L1. Hosted policy is missing a children's-privacy line. `docs/PRIVACY.md`
  has one, the live page does not.
- [ ] L2. No data retention/deletion statement. "Nothing is held remotely;
  deleting the app removes all local data" is sufficient.
- [ ] L3. No "changes to this policy" clause on the hosted page.
- [ ] L4. No Terms of Use / EULA. Apple's standard EULA covers a free
  no-account app, so this is optional, but a short disclaimer of warranties
  and limitation of liability is the single cheapest protection given the app
  makes a behavioral-benefit claim.
- [ ] L5. Trademark clearance for "Buzzkill" has not been done. There is an
  existing Android app named BuzzKill. Search USPTO and the App Store before
  launch. This is a decision for the owner, not something to fix in code.

### App Store review risk

- [ ] A1. Guideline 4.2 minimum functionality is the top rejection risk. The
  binary is an onboarding deck, two bundled shortcut files, and a
  grayscale-status reader. Review notes should foreground the real app
  functionality: the signed bundled shortcuts, the x-callback verification
  loop, and the repair flow.
- [ ] A2. Seven screenshots of Apple's own Settings and Shortcuts UI ship
  inside the app. Instructional use is common and usually passes, but it can
  draw 5.2.5 feedback. Have stylized replacements ready if asked.
- [ ] A3. The research claim in `OnboardingView.swift:77` overstates its single
  citation. Wickord & Quaiser-Pohl (2023) support reduced usage time; the
  "made phones feel less attractive" half is not that study's finding, and the
  literature is mixed. Trim the claim or add the second citation.
- [ ] A4. The marketing site's "Get Buzzkill on the App Store" button currently
  404s because the listing is not live yet. Resolves at launch; do not leave
  it broken while the site is public.

### Low severity / informational

- [ ] I1. The `buzzkill://` callback handler accepts unauthenticated input from
  any app or web page and can flip `didVerifyShortcuts` to true. Impact is
  local UI state only: no privileged action, no data exposure. Optionally add
  a per-run nonce to the x-callback URLs.
- [ ] I2. Another app can register the same `buzzkill://` scheme and intercept
  the Shortcuts callback. The callback carries no secrets, so this only denies
  the completion signal.
- [ ] I3. Shortcuts x-callback dispatches by name, so a shortcut named
  "Buzzkill On" from another source would run instead. Inherent to Shortcuts;
  no fix available.
- [ ] I4. The bundled shortcuts' leaf signing certificates expire
  2027-08-19 and 2027-08-25. Re-sign and ship an update before then or
  installs may start failing.
- [ ] I5. The App Store Connect private key lives in `~/Downloads`. Move it to
  a restricted location.
- [ ] I6. The Android target in this public repo does foreground-app detection
  and requests `WRITE_SECURE_SETTINGS` and `QUERY_ALL_PACKAGES`, which
  contradicts the "no usage monitoring" language in the published policy. Not
  a conflict today since only iOS ships, but the policy must be updated before
  any Android release.

## Correction to B3

B3 was originally filed as a submission blocker. That was overstated. Because
nothing ever leaves the device, there is no processing of personal data by a
controller, so GDPR Art. 13 duties are thin to nonexistent and the "Data Not
Collected" App Privacy declaration is accurate. Naming the publisher is best
practice and costs nothing on a static page, but it was never a blocker and
never put the existing approval at risk.

## Constraint: no new binary

The app was approved on 2026-08-14 after a two-week review. Every fix below is
website or account work that does not require resubmitting a build. The only
in-app item, A3, is deferred to the next routine update.

## Done

- [x] B1/B2. Removed `apps/web` entirely (20 tracked files). This deletes both
  the duplicate privacy policy and the Next.js 16.2.6 install carrying four
  high-severity advisories. GitHub Pages is now the only published site.
- [x] B3/L1/L2/L3. Rewrote `docs/site/privacy.html`: names Marcos Javier
  Klingler as publisher, adds retention and deletion, children's privacy, an
  explicit no-sale line, and a changes clause. Contact stays GitHub issues by
  owner preference. Policy URL is unchanged, so App Store Connect needs no edit.
- [x] L4. Added `docs/site/terms.html` with a warranty disclaimer, a liability
  limitation capped at US$50, an explicit "not medical advice, no guaranteed
  outcome" clause covering the grayscale research claim, and a note that
  Apple's standard EULA governs on conflict. Linked from all three footers.
- [x] B2 follow-through. `docs/PRIVACY.md` was a third copy of the policy and
  is now a pointer to the canonical hosted URL, so the duplication cannot recur.
- [x] Verified all internal links resolve and all four pages are well formed.
  Rendered `terms.html` locally to confirm it picks up the existing stylesheet.

## Still open, owner action

- [ ] Delete the Vercel projects `buzzkill-site` and `web` in the Vercel
  dashboard. Removing the code does not take down the deployment, and the
  vulnerable Next.js build stays live until the project is deleted.
- [ ] Push to `main` so the Pages workflow publishes the new privacy and terms
  pages.
- [ ] I5. Move the App Store Connect `.p8` key out of `~/Downloads`.
- [ ] L5. Trademark search for "Buzzkill" on USPTO and the App Store.
- [ ] A4. The App Store listing still returns 404. Confirm it goes live, since
  the site's download button points at it.

## Research screen (A3, expanded)

Replaced the single unsupported citation with a dedicated research screen
listing six studies. Every entry was verified against Crossref for title,
authors, journal, and year before being written into the app. One earlier
candidate DOI turned out to be an unrelated paper about a completely different
subject and was discarded, which is why the verification step is not optional.

- [x] `ResearchView.swift`. Six studies, each with an accurate one-line
  finding and a link to the published paper. Findings for four of them come
  from verified abstracts (Crossref or the publisher's open repository); the
  two Holte papers have no machine-readable abstract, so their summary lines
  stay close to the authors' own published titles rather than extrapolating.
- [x] A "What this does not show" card stating that these are group averages,
  that findings are mixed, that Zimmermann and Sobolev found no effect of
  reduced screen time on well-being or academic performance, that Dekker and
  Baumgartner found no change in unlock frequency, and that Buzzkill is not a
  medical device. Presenting the null results is deliberate: it is the
  strongest available position against any claim of overpromising.
- [x] An explicit line that Buzzkill did not run the studies and is not
  affiliated with their authors, so citing them implies no endorsement.
- [x] Onboarding copy now reads "In several peer-reviewed experiments,
  switching a phone to grayscale lowered daily screen time," which five of the
  six studies support.
- [x] Reachable from two places: the onboarding "See the research" link and a
  permanent "The research behind Buzzkill" button on the main screen. Both
  present it as a sheet with a Done button, so back navigation works and the
  screen is not stranded inside onboarding.

Verification performed: `xcodebuild` succeeds with no errors or warnings.
`ResearchView` was rendered on an iPhone 17 simulator and confirmed correct,
including scrolling through all six cards and the caveat card. Button-tap
injection was broken in this environment (swipes registered, taps never did,
across a reboot, an erase, a dwell-press, and detached mode), so the two sheet
entry points were not exercised by simulated tap. They use the same
`.sheet(isPresented:)` pattern already shipping twice in `ContentView`.
Worth a manual tap on a real device before the next submission.

## Deferred to the next app update

- [ ] I1. Optional per-run nonce on the `buzzkill://` callback. Local UI state
  only, no data exposure, so this is polish rather than a fix.
- [ ] I4. Re-sign the bundled shortcuts before their certificates expire on
  2027-08-19 and 2027-08-25.

## Review

The audit found no exploitable vulnerability in the shipping iOS app. Its
attack surface is one custom URL scheme whose worst case is flipping a local
setup boolean. The only real security exposure in the repo was the Next.js web
app, which was not even the site the app links to, and it has been removed.

The legal work was documentation rather than code. The two genuine problems
were publishing two divergent privacy policies at once and having no terms at
all while the app made a research-backed behavioral claim. Both are fixed. No
change was made to the iOS target, so the existing approval is untouched.

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

# Buzzkill iOS — repair the guided setup flow

## Plan

- [ ] Replace the misleading Accessibility opener so it tries the Accessibility
  root directly, never intentionally routes to Buzzkill's app-settings page,
  and shows the tap-by-tap fallback when iOS cannot honor the destination.
- [ ] Make the grayscale test wait on an explicit visual confirmation instead
  of advancing from the system status alone.
- [ ] Add a clear “Yes, everything turned gray” action that runs Buzzkill Off,
  verifies color was restored, and only then unlocks the following setup step.
- [ ] Keep a “No, I still see color” repair path that restores color before
  presenting the grayscale-selection instructions.
- [ ] Add persistent Back and Next controls to the four-step setup, with Next
  disabled and explained until the current step's required action is complete.
- [ ] Verify every transition, including Settings return, shortcut cancel/error,
  repair, Back, Next, and final completion; then build the iOS project.

## Review

- Pending implementation and verification.
