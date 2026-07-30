import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @State private var showingSetupGuide = false
    @State private var showingOnboarding = false
    @State private var shouldOpenSetupAfterOnboarding = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    setupCard
                    aboutButton
                    privacyNote
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Buzzkill")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSetupGuide) {
                AutomationGuide(
                    installShortcut: viewModel.installShortcut,
                    openedShortcutInstallers: viewModel.openedShortcutInstallers,
                    shortcutTestPhase: viewModel.shortcutTestPhase,
                    testShortcut: viewModel.testShortcut,
                    restoreColorAfterFailedVisualCheck: viewModel.restoreColorAfterFailedVisualCheck,
                    restoreColorBeforeLeavingTest: viewModel.restoreColorBeforeLeavingTest,
                    openSettings: viewModel.openSystemSettings,
                    openShortcuts: viewModel.openAutomationCreator,
                    finish: {
                        viewModel.didFinishAutomation = true
                    }
                )
            }
            .fullScreenCover(
                isPresented: $showingOnboarding,
                onDismiss: handleOnboardingDismiss
            ) {
                OnboardingView(
                    canClose: didCompleteOnboarding,
                    onClose: { showingOnboarding = false },
                    onStartSetup: finishOnboarding
                )
            }
        }
        .onAppear(perform: presentOnboardingIfNeeded)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refreshGrayscaleStatus() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.grayscaleStatusDidChangeNotification)) { _ in
            viewModel.refreshGrayscaleStatus()
        }
        .onOpenURL(perform: viewModel.handleShortcutCallback)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            mascot
                .frame(maxWidth: .infinity, alignment: .center)
            heroCopy
        }
        .padding(.top, 4)
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COLOR, ON YOUR TERMS")
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text("Make the feed dull.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-1)
            Text("Keep access. Lose the visual sugar. Buzzkill turns selected apps grayscale while they’re open.")
                .foregroundStyle(.secondary)
        }
    }

    private var mascot: some View {
        Image("OnboardingWelcome")
            .resizable()
            .scaledToFit()
            .frame(width: 138, height: 138)
            .accessibilityHidden(true)
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                viewModel.didFinishAutomation ? "SETUP COMPLETE" : "ABOUT 5 MINUTES",
                systemImage: viewModel.didFinishAutomation ? "checkmark.circle.fill" : "clock"
            )
            .font(.caption.weight(.black))
            .tracking(0.8)
            .foregroundStyle(.secondary)

            Text(viewModel.didFinishAutomation ? "Buzzkill is ready" : "Choose the apps to dull")
                .font(.title3.bold())

            Text(
                viewModel.didFinishAutomation
                    ? "Review the Shortcuts setup or change which apps trigger grayscale."
                    : "A guided setup connects two native Apple automations—one when your chosen apps open and one when they close."
            )
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showingSetupGuide = true
            } label: {
                Label(viewModel.didFinishAutomation ? "Review setup" : "Set up Buzzkill", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            if viewModel.didVerifyShortcuts || viewModel.didFinishAutomation {
                GuideSecondaryButton(title: "Restart setup guide") {
                    viewModel.resetSetupProgress()
                    showingSetupGuide = true
                }
                Text("This resets Buzzkill’s checklist. It does not delete your shortcuts or automations.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var aboutButton: some View {
        GuideSecondaryButton(title: "Why Buzzkill works") {
            showingOnboarding = true
        }
    }

    private var privacyNote: some View {
        Label(
            "No account, VPN, or screen recording. Apple runs the automations locally.",
            systemImage: "lock.shield.fill"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    private func presentOnboardingIfNeeded() {
        if !didCompleteOnboarding {
            showingOnboarding = true
        }
    }

    private func finishOnboarding() {
        didCompleteOnboarding = true
        shouldOpenSetupAfterOnboarding = true
        showingOnboarding = false
    }

    private func handleOnboardingDismiss() {
        guard shouldOpenSetupAfterOnboarding else { return }
        shouldOpenSetupAfterOnboarding = false
        showingSetupGuide = true
    }
}

private struct AutomationGuide: View {
    let installShortcut: (BundledShortcut) -> Void
    let openedShortcutInstallers: Set<BundledShortcut>
    let shortcutTestPhase: ShortcutTestPhase
    let testShortcut: (BundledShortcut) -> Void
    let restoreColorAfterFailedVisualCheck: () -> Void
    let restoreColorBeforeLeavingTest: () -> Void
    let openSettings: () -> Void
    let openShortcuts: () -> Void
    let finish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Group {
                    switch page {
                    case 0:
                    InstallShortcutsPage(
                        openedInstallers: openedShortcutInstallers,
                        install: installShortcut,
                        continueAction: { page = 1 }
                    )
                    case 1:
                    TestShortcutsPage(
                        phase: shortcutTestPhase,
                        testShortcut: testShortcut,
                        restoreColorAfterFailedVisualCheck: restoreColorAfterFailedVisualCheck,
                        openSettings: openSettings,
                        continueAction: { page = 2 }
                    )
                    case 2:
                    OpenAutomationPage(
                        openShortcuts: openShortcuts,
                        continueAction: { page = 3 }
                    )
                    default:
                    CloseAutomationPage(
                        openShortcuts: openShortcuts,
                        finish: completeSetup
                    )
                    }
                }
                .id(page)
                .transition(.opacity)
                progress
            }
            .animation(.easeInOut(duration: 0.2), value: page)
            .navigationTitle("Set up Buzzkill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if page == 0 {
                        Button("Close", action: closeGuide)
                    } else {
                        Button(action: goBack) {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
                }
                if page > 0 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Close", action: closeGuide)
                    }
                }
            }
        }
    }

    private var progress: some View {
        HStack(spacing: 7) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: index == page ? 28 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: page)
        .padding(.bottom, 20)
        .accessibilityLabel("Setup step \(page + 1) of 4")
    }

    private func completeSetup() {
        finish()
        dismiss()
    }

    private func goBack() {
        restoreColorIfNeeded()
        page -= 1
    }

    private func closeGuide() {
        restoreColorIfNeeded()
        dismiss()
    }

    private func restoreColorIfNeeded() {
        if shortcutTestPhase == .onVerified {
            restoreColorBeforeLeavingTest()
        }
    }
}

private struct OpenAutomationPage: View {
    let openShortcuts: () -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 3)
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 44, weight: .medium))
                    Text("When an app opens")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Make the rule that turns grayscale on:")
                        .foregroundStyle(.secondary)

                    SetupInstruction(
                        number: 1,
                        text: "In Shortcuts, tap Automation at the bottom."
                    )
                    SetupScreenshot(
                        imageName: "ShortcutsAutomation",
                        caption: "If this is your first rule, tap New Automation. Otherwise, tap +.",
                        cropAlignment: .bottom
                    )
                    SetupInstruction(
                        number: 2,
                        text: "Tap New Automation, search for App, then tap App."
                    )
                    SetupInstruction(
                        number: 3,
                        text: "Tap Choose and select every app Buzzkill should make grayscale."
                    )
                    SetupInstruction(
                        number: 4,
                        text: "Keep Is Opened selected and choose Run Immediately."
                    )
                    SetupScreenshot(
                        imageName: "ShortcutsAppTrigger",
                        caption: "For this first rule: Is Opened + Run Immediately.",
                        cropAlignment: .center
                    )
                    SetupInstruction(
                        number: 5,
                        text: "Tap Next, then choose the installed Buzzkill On shortcut."
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            VStack(spacing: 12) {
                GuideButton(
                    title: "Open Shortcuts",
                    icon: "arrow.up.forward.app",
                    action: openShortcuts
                )
                GuideSecondaryButton(
                    title: "Next: Make the close rule",
                    action: continueAction
                )
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
    }
}

private struct CloseAutomationPage: View {
    let openShortcuts: () -> Void
    let finish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 4)
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 44, weight: .medium))
                    Text("When an app closes")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Make the matching rule that brings color back:")
                        .foregroundStyle(.secondary)

                    SetupInstruction(
                        number: 1,
                        text: "In Shortcuts, return to the Automation tab and tap +."
                    )
                    SetupInstruction(
                        number: 2,
                        text: "Search for App, tap App, then choose the same apps as before."
                    )
                    SetupInstruction(
                        number: 3,
                        text: "Turn off Is Opened and turn on Is Closed."
                    )
                    SetupInstruction(
                        number: 4,
                        text: "Choose Run Immediately, then tap Next."
                    )
                    SetupScreenshot(
                        imageName: "ShortcutsClosedTrigger",
                        caption: "For this second rule: Is Closed + Run Immediately.",
                        cropAlignment: .center
                    )
                    SetupInstruction(
                        number: 5,
                        text: "Select the installed Buzzkill Off shortcut."
                    )
                    Text("You should now have two rules: Buzzkill On for Is Opened, and Buzzkill Off for Is Closed.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            VStack(spacing: 12) {
                GuideButton(
                    title: "Open Shortcuts",
                    icon: "arrow.up.forward.app",
                    action: openShortcuts
                )
                GuideSecondaryButton(title: "Finish setup", action: finish)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
    }
}

private struct StepHeader: View {
    let step: Int

    var body: some View {
        Text("STEP \(step) OF 4")
            .font(.caption.weight(.bold))
            .tracking(1)
            .foregroundStyle(.secondary)
    }
}

private struct SetupInstruction: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold())
                .frame(width: 28, height: 28)
                .background(Color.primary)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .clipShape(Circle())
                .accessibilityHidden(true)
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number). \(text)")
    }
}

private struct SetupScreenshot: View {
    let imageName: String
    let caption: String
    let cropAlignment: Alignment

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 330, alignment: cropAlignment)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.12))
                }
                .accessibilityHidden(true)
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct GuideButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .systemBackground))
        }
        .buttonStyle(.borderedProminent)
        .tint(.primary)
    }
}

private struct GuideSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.bordered)
        .tint(.primary)
    }
}

private struct InstallShortcutsPage: View {
    let openedInstallers: Set<BundledShortcut>
    let install: (BundledShortcut) -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 1)
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 44, weight: .medium))
                    Text("Install two tiny shortcuts")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Buzzkill already made the Color Filters actions. Add both to Shortcuts, then come back here. You won’t have to build either shortcut yourself.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    VStack(spacing: 12) {
                        ForEach(BundledShortcut.allCases) { shortcut in
                            Button {
                                install(shortcut)
                            } label: {
                                Label(
                                    openedInstallers.contains(shortcut)
                                        ? "\(shortcut.displayName) installer opened"
                                        : "Install \(shortcut.displayName)",
                                    systemImage: openedInstallers.contains(shortcut)
                                        ? "checkmark.circle.fill"
                                        : "square.and.arrow.down"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.primary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            Button(action: continueAction) {
                Text("Next: Test the shortcuts")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .disabled(openedInstallers.count < BundledShortcut.allCases.count)
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
    }
}

private struct TestShortcutsPage: View {
    let phase: ShortcutTestPhase
    let testShortcut: (BundledShortcut) -> Void
    let restoreColorAfterFailedVisualCheck: () -> Void
    let openSettings: () -> Void
    let continueAction: () -> Void

    var body: some View {
        Group {
            if phase == .failed(.filterIsNotGrayscale) {
                GrayscaleRepairPage(
                    openSettings: openSettings,
                    retry: { testShortcut(.grayscaleOn) }
                )
            } else {
                testPage
            }
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .verified {
                continueAction()
            }
        }
    }

    private var testPage: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 2)
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .medium))
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    ColorTestCard()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            actionButton
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
        }
    }

    private var icon: String {
        switch phase {
        case .running:
            "hourglass"
        case .onVerified:
            "circle.lefthalf.filled"
        case .verified:
            "checkmark.seal.fill"
        case .failed:
            "exclamationmark.triangle"
        case .ready:
            "checkmark.circle"
        }
    }

    private var title: String {
        switch phase {
        case .ready:
            "Make sure it works"
        case .running(let shortcut):
            "Testing \(shortcut.displayName)…"
        case .onVerified:
            "Did the colors turn gray?"
        case .verified:
            "Both shortcuts work"
        case .failed:
            "One thing needs fixing"
        }
    }

    private var detail: String {
        switch phase {
        case .ready:
            "Buzzkill will run the On shortcut, return here, and confirm your display really changed to grayscale."
        case .running:
            "Shortcuts is running the test. Buzzkill will reopen automatically when it finishes."
        case .onVerified:
            "Take as long as you need to check the stripes below. Nothing will advance until you answer."
        case .verified:
            "Grayscale turned on and color came back. Your two shortcuts are installed and configured correctly."
        case .failed(let failure):
            failureMessage(failure)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch phase {
        case .ready:
            primaryButton("Test Buzzkill On", icon: "play.fill") {
                testShortcut(.grayscaleOn)
            }
        case .running:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding()
        case .onVerified:
            VStack(spacing: 12) {
                primaryButton("Yes, it turned gray — Continue", icon: "checkmark") {
                    testShortcut(.grayscaleOff)
                }
                GuideSecondaryButton(title: "No, I still see color") {
                    restoreColorAfterFailedVisualCheck()
                }
            }
        case .verified:
            primaryButton("Next: Create the open rule", icon: "arrow.right") {
                continueAction()
            }
        case .failed(let failure):
            primaryButton(retryTitle(failure), icon: "arrow.clockwise") {
                testShortcut(retryShortcut(failure))
            }
        }
    }

    private func primaryButton(
        _ title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(uiColor: .systemBackground))
        }
        .buttonStyle(.borderedProminent)
        .tint(.primary)
    }

    private func failureMessage(_ failure: ShortcutTestFailure) -> String {
        switch failure {
        case .couldNotOpen(let shortcut), .couldNotRun(let shortcut):
            "\(shortcut.displayName) couldn’t run. Go back one step, reinstall it, then retry."
        case .cancelled(let shortcut):
            "\(shortcut.displayName) was cancelled before it finished. Retry when you’re ready."
        case .filterIsNotGrayscale:
            "Buzzkill On ran, but the display did not become grayscale. In Settings, choose Accessibility → Display & Text Size → Color Filters → Grayscale, then retry."
        case .colorWasNotRestored:
            "Buzzkill Off ran, but grayscale stayed on. Go back one step, reinstall Buzzkill Off, then retry."
        }
    }

    private func retryTitle(_ failure: ShortcutTestFailure) -> String {
        switch retryShortcut(failure) {
        case .grayscaleOn: "Retry Buzzkill On"
        case .grayscaleOff: "Retry Buzzkill Off"
        }
    }

    private func retryShortcut(_ failure: ShortcutTestFailure) -> BundledShortcut {
        switch failure {
        case .couldNotOpen(let shortcut),
             .couldNotRun(let shortcut),
             .cancelled(let shortcut):
            shortcut
        case .filterIsNotGrayscale:
            .grayscaleOn
        case .colorWasNotRestored:
            .grayscaleOff
        }
    }
}

private struct ColorTestCard: View {
    private let colors: [Color] = [.pink, .orange, .yellow, .green, .cyan, .blue, .purple]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("COLOR CHECK")
                .font(.caption.bold())
                .tracking(1)
            HStack(spacing: 0) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    Rectangle()
                        .fill(color)
                }
            }
            .frame(height: 74)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text("After Buzzkill On runs, every stripe above should look black, white, or gray.")
                .font(.subheadline)
        }
        .padding(18)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Color check. After Buzzkill On runs, every stripe should look black, white, or gray.")
    }
}

private struct GrayscaleRepairPage: View {
    let openSettings: () -> Void
    let retry: () -> Void
    @State private var showingVisualGuide = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 2)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 44, weight: .medium))
                    Text("Still seeing color?")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Buzzkill restored normal color before bringing you here. Choose Grayscale once, then retry the visual test.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Five taps, fully pictured", systemImage: "rectangle.stack.fill")
                            .font(.headline)
                        Text("Open the visual guide and swipe through one Apple-style screen for every tap.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            showingVisualGuide = true
                        } label: {
                            Label("View tap-by-tap guide", systemImage: "hand.tap.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.primary)
                    }
                    .padding(18)
                    .background(
                        Color.primary.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
                    Text("Try Accessibility below. If iOS lands on Buzzkill’s settings, tap “Settings” in the top-left to return to the main Settings screen, then follow the pictures.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            VStack(spacing: 12) {
                GuideButton(
                    title: "Open Accessibility",
                    icon: "gear",
                    action: openSettings
                )
                GuideSecondaryButton(title: "Retry Buzzkill On", action: retry)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
        .fullScreenCover(isPresented: $showingVisualGuide) {
            GrayscaleVisualGuide()
        }
    }
}

private struct GrayscaleVisualGuide: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStep = 0

    private let steps = [
        GrayscaleTutorialStep(
            number: 1,
            title: "Tap Accessibility",
            caption: "In Settings, tap Accessibility.",
            imageName: "GrayscaleGuideSettings",
            cropAlignment: .center
        ),
        GrayscaleTutorialStep(
            number: 2,
            title: "Tap Display & Text Size",
            caption: "Under Vision, tap Display & Text Size.",
            imageName: "GrayscaleGuideAccessibility",
            cropAlignment: .center
        ),
        GrayscaleTutorialStep(
            number: 3,
            title: "Tap Color Filters",
            caption: "Scroll toward the bottom, then tap Color Filters.",
            imageName: "GrayscaleGuideDisplayText",
            cropAlignment: .bottom
        ),
        GrayscaleTutorialStep(
            number: 4,
            title: "Turn on Color Filters",
            caption: "Turn on the Color Filters switch at the top.",
            imageName: "GrayscaleGuideEnableFilters",
            cropAlignment: .center
        ),
        GrayscaleTutorialStep(
            number: 5,
            title: "Tap Grayscale",
            caption: "Select Grayscale, then return to Buzzkill and retry.",
            imageName: "GrayscaleGuideChooseGrayscale",
            cropAlignment: .top
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TabView(selection: $selectedStep) {
                    ForEach(steps) { step in
                        tutorialPage(step)
                            .tag(step.number - 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                stepIndicator
                navigationButtons
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Pick Grayscale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
    }

    private func tutorialPage(_ step: GrayscaleTutorialStep) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("TAP \(step.number) OF \(steps.count)")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(.secondary)
                Text(step.title)
                    .font(.system(.title, design: .rounded, weight: .bold))
                Image(step.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 390, alignment: step.cropAlignment)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.primary.opacity(0.1))
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 5)
                    .accessibilityHidden(true)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text(step.caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tap \(step.number) of \(steps.count). \(step.title). \(step.caption)")
    }

    private var stepIndicator: some View {
        HStack(spacing: 7) {
            ForEach(steps) { step in
                Capsule()
                    .fill(
                        step.number - 1 == selectedStep
                            ? Color.primary
                            : Color.secondary.opacity(0.25)
                    )
                    .frame(
                        width: step.number - 1 == selectedStep ? 28 : 8,
                        height: 8
                    )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedStep)
        .accessibilityLabel("Tutorial page \(selectedStep + 1) of \(steps.count)")
    }

    private var navigationButtons: some View {
        HStack {
            if selectedStep > 0 {
                Button("Back") {
                    selectedStep -= 1
                }
                .buttonStyle(.bordered)
                .tint(.primary)
            }
            Spacer()
            Button(selectedStep == steps.count - 1 ? "Done" : "Next") {
                if selectedStep == steps.count - 1 {
                    dismiss()
                } else {
                    selectedStep += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .foregroundStyle(Color(uiColor: .systemBackground))
        }
    }
}

private struct GrayscaleTutorialStep: Identifiable {
    let number: Int
    let title: String
    let caption: String
    let imageName: String
    let cropAlignment: Alignment

    var id: Int { number }
}
