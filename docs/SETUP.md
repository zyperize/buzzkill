# Buzzkill — developer setup

This is the one-stop guide for getting the project running on a new Mac.
Everything in v1 is local-first, so you can demo all three targets without
signing up for any paid service.

## What's in the repo

```
Buzzkill/
├── android/                 native Android app (Kotlin + Compose)
├── apps/web/                Next.js landing/demo
├── ios/                     native iOS app (SwiftUI)
├── docs/                    research, plans, this file
└── scripts/
```

## Prerequisites by target

| Target  | Tooling required                          | Verifiable on Mac without device? |
|---------|-------------------------------------------|-----------------------------------|
| Web     | Node 20+, npm                             | Yes                               |
| iOS     | Xcode 16+, XcodeGen                       | Yes (simulator)                   |
| Android | JDK 17, Android SDK (API 35), Gradle 8.7  | Build yes; real grayscale needs a physical device and privileged access |

## One-time Mac setup

### 1. Web

```bash
cd apps/web
npm install
npm run dev          # http://localhost:3000
npm run build        # production build smoke check
```

### 2. iOS

Install Xcode 16 from the App Store. Then:

```bash
brew install xcodegen
cd ios
xcodegen generate
open Buzzkill.xcodeproj
```

In Xcode:

- Pick a simulator (iPhone 16, latest iOS).
- ⌘R to run.

The app guides the user through the supported system setup. On each physical
iPhone, first configure Color Filters to Grayscale, then install the bundled
**Buzzkill On** and **Buzzkill Off** shortcuts. Create two app automations:
opened runs Buzzkill On and closed runs Buzzkill Off.

### 3. Android

Buzzkill on Android needs three pieces locally:

1. **JDK 17.** `brew install --cask temurin@17`. After install:
   ```bash
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)
   ```
   Add that line to your `~/.zshrc`.

2. **Android Studio** (recommended). It bundles the Android SDK,
   build-tools, and a friendly emulator. Open `/android` in Android Studio
   and let it sync.

3. **Or CLI-only**: install [Android command-line tools](https://developer.android.com/tools/sdkmanager),
   then:
   ```bash
   sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"
   export ANDROID_HOME="$HOME/Library/Android/sdk"
   ```

Once the SDK is in place:

```bash
cd android
./gradlew :app:assembleDebug
./gradlew :app:installDebug    # to a connected device or emulator
```

The Gradle wrapper (`gradlew`, `gradle/wrapper/*`) is already committed,
so you don't need a system-wide Gradle.

## Running Android grayscale end-to-end

Android Buzzkill changes the real device-wide grayscale setting; it does not
draw an overlay. This needs a physical Android device because the app must be
granted the privileged `WRITE_SECURE_SETTINGS` permission once over ADB.

On a connected device or running emulator:

1. Launch Buzzkill.
2. In Buzzkill, tap **Copy ADB command** and run it from the computer.
3. Tap **Open Accessibility settings** and enable Buzzkill.
4. Pick at least one target app (for example Instagram).
5. Turn on **Automatic grayscale**.
6. Open the target app: the whole display becomes grayscale. Leave it: color
   returns. The target app remains fully usable throughout.

## Re-generating Xcode after editing project.yml

```bash
cd ios
xcodegen generate
```

## Re-running iOS simulator smoke build from CLI

```bash
cd ios
xcodebuild \
  -project Buzzkill.xcodeproj \
  -scheme Buzzkill \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -configuration Debug build
```

## Re-running web build

```bash
cd apps/web
npm run lint
npm run build
```

## Common gotchas

- **Android: "JAVA_HOME not set"** — set JAVA_HOME to JDK 17, not the
  default macOS Java stub.
- **Android: "SDK location not found"** — set `ANDROID_HOME` in your
  shell, OR open the project once in Android Studio (it writes
  `local.properties`).
- **iOS Simulator:** Shortcuts and system actions are incomplete in current
  simulator runtimes. Validate shortcut installation and automations on a
  physical iPhone.
