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
                    .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
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
    let openShortcuts: () -> Void
    let finish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var openedInstallers: Set<BundledShortcut> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TabView(selection: $page) {
                    OnboardingPage(
                        step: 1,
                        title: "Pick Grayscale",
                        detail: "In Settings, go to Accessibility → Display & Text Size → Color Filters. Choose Grayscale, then turn Color Filters back off. iPhone does not allow an app to open this exact page directly.",
                        primaryTitle: "I picked Grayscale",
                        primaryIcon: "circle.lefthalf.filled",
                        primaryAction: { page = 1 },
                        showContinue: false,
                        continueTitle: "I picked Grayscale",
                        continueAction: { page = 1 }
                    )
                    .tag(0)
                    InstallShortcutsPage(
                        openedInstallers: openedInstallers,
                        install: install,
                        continueAction: { page = 2 }
                    )
                    .tag(1)
                    OnboardingPage(
                        step: 3,
                        title: "When an app opens",
                        detail: "In Shortcuts, tap Automation → + → App. Pick your apps, choose Is Opened and Run Immediately, then select the installed Buzzkill On shortcut.",
                        primaryTitle: "Open Shortcuts",
                        primaryIcon: "arrow.up.forward.app",
                        primaryAction: openShortcuts,
                        showContinue: true,
                        continueTitle: "I made the open rule",
                        continueAction: { page = 3 }
                    )
                    .tag(2)
                    OnboardingPage(
                        step: 4,
                        title: "When an app closes",
                        detail: "Make one more App automation for the same apps. Choose Is Closed and Run Immediately, then select the installed Buzzkill Off shortcut.",
                        primaryTitle: "Open Shortcuts",
                        primaryIcon: "arrow.up.forward.app",
                        primaryAction: openShortcuts,
                        showContinue: true,
                        continueTitle: "Finish setup",
                        continueAction: completeSetup
                    )
                    .tag(3)
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

    private func install(_ shortcut: BundledShortcut) {
        installShortcut(shortcut)
        openedInstallers.insert(shortcut)
    }

    private func completeSetup() {
        finish()
        dismiss()
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
        VStack(alignment: .leading, spacing: 22) {
            Text("STEP \(step) OF 4")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Image(systemName: primaryIcon)
                .font(.system(size: 44, weight: .medium))
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-0.7)
            Text(detail)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: primaryAction) {
                Label(primaryTitle, systemImage: primaryIcon)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            if showContinue {
                Button(continueTitle, action: continueAction)
                    .buttonStyle(.bordered)
                    .tint(.primary)
            }
        }
        .padding(28)
    }
}

private struct InstallShortcutsPage: View {
    let openedInstallers: Set<BundledShortcut>
    let install: (BundledShortcut) -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("STEP 2 OF 4")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44, weight: .medium))
            Text("Install two tiny shortcuts")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-0.7)
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
            Spacer()
            Button("Both are installed", action: continueAction)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)
                .disabled(openedInstallers.count < BundledShortcut.allCases.count)
        }
        .padding(28)
    }
}
