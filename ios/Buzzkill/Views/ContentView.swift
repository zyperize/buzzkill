import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingSetupGuide = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    statusCard
                    setupCard
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
                    openSettings: viewModel.openSystemSettings,
                    openShortcuts: viewModel.openAutomationCreator,
                    finish: {
                        viewModel.didFinishAutomation = true
                    }
                )
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refreshGrayscaleStatus() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.grayscaleStatusDidChangeNotification)) { _ in
            viewModel.refreshGrayscaleStatus()
        }
        .onOpenURL(perform: viewModel.handleShortcutCallback)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COLOR, ON YOUR TERMS")
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text("Make the feed dull.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-1)
            Text("Set it up once, then selected apps can switch your whole display to grayscale while they are open.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private var statusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: viewModel.isGrayscaleEnabled ? "circle.lefthalf.filled" : "circle")
                .font(.system(size: 34))
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isGrayscaleEnabled ? "Grayscale is on" : "Grayscale is off")
                    .font(.headline)
                Text(viewModel.statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Grayscale status")
        .accessibilityValue(viewModel.isGrayscaleEnabled ? "On" : "Off")
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set up grayscale").font(.title3.bold())
            Text("A short, guided setup for the two system automations that turn grayscale on and off.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                showingSetupGuide = true
            } label: {
                Label(viewModel.didFinishAutomation ? "Review setup" : "Check setup", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            if viewModel.didVerifyShortcuts || viewModel.didFinishAutomation {
                Button("Start over") {
                    viewModel.resetSetupProgress()
                    showingSetupGuide = true
                }
                .buttonStyle(.bordered)
                .tint(.primary)
            }
        }
        .padding(20)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var privacyNote: some View {
        Text("Buzzkill does not block apps, limit time, or read what you do in another app. Apple runs the automation locally.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

private struct AutomationGuide: View {
    let installShortcut: (BundledShortcut) -> Void
    let openedShortcutInstallers: Set<BundledShortcut>
    let shortcutTestPhase: ShortcutTestPhase
    let testShortcut: (BundledShortcut) -> Void
    let openSettings: () -> Void
    let openShortcuts: () -> Void
    let finish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TabView(selection: $page) {
                    GrayscaleSetupPage(
                        openSettings: openSettings,
                        continueAction: { page = 1 }
                    )
                    .tag(0)
                    InstallShortcutsPage(
                        openedInstallers: openedShortcutInstallers,
                        install: installShortcut,
                        continueAction: { page = 2 }
                    )
                    .tag(1)
                    TestShortcutsPage(
                        phase: shortcutTestPhase,
                        testShortcut: testShortcut,
                        continueAction: { page = 3 }
                    )
                    .tag(2)
                    OpenAutomationPage(
                        openShortcuts: openShortcuts,
                        continueAction: { page = 4 }
                    )
                    .tag(3)
                    OnboardingPage(
                        step: 5,
                        title: "When an app closes",
                        detail: "Make one more App automation for the same apps. Choose Is Closed and Run Immediately, then select the installed Buzzkill Off shortcut.",
                        primaryTitle: "Open Shortcuts",
                        primaryIcon: "arrow.up.forward.app",
                        primaryAction: openShortcuts,
                        showContinue: true,
                        continueTitle: "Finish setup",
                        continueAction: completeSetup
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                progress
            }
            .navigationTitle("Set up Buzzkill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }

    private var progress: some View {
        HStack(spacing: 7) {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: index == page ? 28 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: page)
        .padding(.bottom, 20)
        .accessibilityLabel("Setup step \(page + 1) of 5")
    }

    private func completeSetup() {
        finish()
        dismiss()
    }
}

private struct GrayscaleSetupPage: View {
    let openSettings: () -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: 1)
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.system(size: 44, weight: .medium))
                    Text("Pick Grayscale")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Buzzkill can open iPhone Settings for you. From there, make these three taps:")
                        .foregroundStyle(.secondary)
                    SetupInstruction(number: 1, text: "Tap Accessibility")
                    SetupInstruction(number: 2, text: "Tap Display & Text Size")
                    SetupInstruction(number: 3, text: "Tap Color Filters")
                    Text("Choose Grayscale, then turn Color Filters back off. Buzzkill On will turn it on only when your selected apps open.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            VStack(spacing: 12) {
                GuideButton(
                    title: "Open iPhone Settings",
                    icon: "gearshape.fill",
                    action: openSettings
                )
                Button("I picked Grayscale", action: continueAction)
                    .buttonStyle(.bordered)
                    .tint(.primary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
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
                    StepHeader(step: 4)
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
                        caption: "If this is your first rule, tap New Automation. Otherwise, tap +."
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
                        caption: "For this first rule: Is Opened + Run Immediately."
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
                Button("I made the open rule", action: continueAction)
                    .buttonStyle(.bordered)
                    .tint(.primary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
    }
}

private struct OnboardingPage: View {
    let step: Int
    let title: String
    let detail: String
    let primaryTitle: String
    let primaryIcon: String
    let primaryAction: () -> Void
    let showContinue: Bool
    let continueTitle: String
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    StepHeader(step: step)
                    Image(systemName: primaryIcon)
                        .font(.system(size: 44, weight: .medium))
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            VStack(spacing: 12) {
                GuideButton(
                    title: primaryTitle,
                    icon: primaryIcon,
                    action: primaryAction
                )
                if showContinue {
                    Button(continueTitle, action: continueAction)
                        .buttonStyle(.bordered)
                        .tint(.primary)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
    }
}

private struct StepHeader: View {
    let step: Int

    var body: some View {
        Text("STEP \(step) OF 5")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFit()
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

private struct InstallShortcutsPage: View {
    let openedInstallers: Set<BundledShortcut>
    let install: (BundledShortcut) -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("STEP 2 OF 5")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.secondary)
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
                                        ? "\(shortcut.displayName) opened"
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
            Button("Both are installed", action: continueAction)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .disabled(openedInstallers.count < BundledShortcut.allCases.count)
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
        }
    }
}

private struct TestShortcutsPage: View {
    let phase: ShortcutTestPhase
    let testShortcut: (BundledShortcut) -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("STEP 3 OF 5")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .medium))
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
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
            "Grayscale works"
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
            "The On shortcut passed. Restore color now to test Buzzkill Off and leave your phone looking normal."
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
            primaryButton("Restore Color", icon: "paintpalette.fill") {
                testShortcut(.grayscaleOff)
            }
        case .verified:
            primaryButton("Continue", icon: "arrow.right") {
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
