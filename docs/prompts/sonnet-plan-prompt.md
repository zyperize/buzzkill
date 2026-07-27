/goal Build the full product and technical plan for a mobile app whose purpose is to make social media less addictive by turning the screen black-and-white whenever the user opens selected social media apps.

You are not coding yet. You are acting as a senior mobile architect, product engineer, and execution planner.

I want a root-up plan from scratch for both Android and iOS with the LEAST amount of implementation pain, OS-policy pain, and long-term maintenance pain.

Project context:
- New repo from scratch
- App name: Buzzkill
- Goal is a real shippable product, not a hacky demo
- Priority is reliability, simplicity, and least fragile architecture
- Prefer local-first and no unnecessary backend
- If one platform is much more feasible than the other, say so clearly
- If iOS cannot truly support the exact behavior due to platform restrictions, do not hand-wave it — explain the limitation clearly and design the closest valid product instead
- I care more about “works in real life” than code sharing for its own sake

Product concept:
- User selects social media apps they want to make less stimulating
- When those apps are opened, the experience becomes grayscale / black-and-white
- User should have clear controls:
  - on/off master toggle
  - selected apps list
  - schedule mode
  - temporary bypass / emergency override
  - onboarding that explains permissions and limitations honestly
- App should feel modern, minimal, and slightly playful, not preachy

Your task:
Produce an extremely detailed implementation plan with these sections:

1. Product definition
- one-sentence product definition
- target users
- core value proposition
- non-goals

2. Feasibility analysis by platform
- Android: what is truly possible, what permissions are needed, what implementation paths exist
- iOS: what is truly possible, what is not possible, what Apple restrictions matter
- explicit recommendation on whether to build Android-first, iOS companion-only, or some other phased rollout

3. Best tech stack with least issues
- exact recommended stack for Android
- exact recommended stack for iOS
- whether to use native or cross-platform, and why
- backend recommendation: none vs optional backend vs required backend
- local storage recommendation
- analytics/logging recommendation
- CI/CD recommendation
- testing stack recommendation

4. Architecture
- app architecture for Android
- app architecture for iOS
- module/folder structure for each
- state management choice
- permission handling design
- how grayscale enforcement should actually work on each platform
- how config/rules should be stored

5. UX flows
- onboarding
- permission grant flow
- app selection flow
- grayscale activation flow
- bypass flow
- schedule flow
- settings flow
- edge-case handling and user messaging

6. OS and policy risks
- App Store risks
- Play Store risks
- privacy/security concerns
- accessibility concerns
- battery/performance concerns
- what could cause rejection or breakage

7. MVP definition
- smallest real v1 that is actually worth shipping
- must be broken into Android MVP and iOS MVP separately if needed

8. Phased roadmap
- Phase 0: technical spike / feasibility validation
- Phase 1: Android MVP
- Phase 2: iOS strategy / constrained implementation
- Phase 3: polish, telemetry, launch prep

9. Detailed implementation plan
Make this very concrete and execution-ready:
- exact repo structure
- exact technologies/libraries/packages
- exact milestone breakdown
- engineering tasks in dependency order
- testing tasks
- release tasks
- observability tasks
- documentation tasks

10. Recommendation and final call
- the single best build strategy with least pain
- the biggest trap to avoid
- what you would build first this week

Output requirements:
- be brutally honest about platform limitations
- optimize for least fragile architecture
- avoid speculative complexity
- prefer native if that reduces risk
- do not suggest anything that relies on private APIs or App Store rejection bait
- write in clear plain English
- include a final section called “If I were building this tomorrow”
