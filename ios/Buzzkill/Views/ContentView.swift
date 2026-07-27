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
                    shortcutSupport: viewModel.shortcutSupport,
                    openColorFilters: viewModel.openColorFiltersSettings,
                    openAccessibilityShortcut: viewModel.openAccessibilityShortcutSettings,
                    openShortcuts: viewModel.openAutomationCreator,
                    finish: {
                        viewModel.shortcutSupport = .setColorFiltersAvailable
                        viewModel.didFinishAutomation = true
                    },
                    markManualFallback: {
                        viewModel.shortcutSupport = .manualFallback
                        viewModel.didFinishAutomation = false
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
            Text(viewModel.shortcutSupport == .manualFallback
                ? "Automatic Color Filter actions are unavailable on this iPhone. Use the manual Accessibility Shortcut instead."
                : "First confirm that this iPhone exposes Set Color Filters in Shortcuts. Only then create the automation.")
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
    let shortcutSupport: ShortcutSupport
    let openColorFilters: () -> Void
    let openAccessibilityShortcut: () -> Void
    let openShortcuts: () -> Void
    let finish: () -> Void
    let markManualFallback: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var showingManualFallback = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TabView(selection: $page) {
                    OnboardingPage(
                        step: 1,
                        title: "Pick Grayscale",
                        detail: "Set the filter Buzzkill will use. Turn Color Filters on, choose Grayscale, then turn it back off.",
                        primaryTitle: "Open Color Filters",
                        primaryIcon: "circle.lefthalf.filled",
                        primaryAction: openColorFilters,
                        continueTitle: "I picked Grayscale",
                        continueAction: { page = 1 }
                    )
                    .tag(0)
                    OnboardingPage(
                        step: 2,
                        title: "When an app opens",
                        detail: "Create an App automation in Shortcuts. Choose your apps, choose Is Opened, then set Color Filters to On. Pick Run Immediately.",
                        primaryTitle: "Open Shortcuts",
                        primaryIcon: "arrow.up.forward.app",
                        primaryAction: openShortcuts,
                        continueTitle: "I made the open rule",
                        continueAction: { page = 2 }
                    )
                    .tag(1)
                    OnboardingPage(
                        step: 3,
                        title: "When an app closes",
                        detail: "Make one more App automation for the same apps. Choose Is Closed, set Color Filters to Off, and pick Run Immediately.",
                        primaryTitle: "Open Shortcuts",
                        primaryIcon: "arrow.up.forward.app",
                        primaryAction: openShortcuts,
                        continueTitle: "I made the close rule",
                        continueAction: { page = 3 }
                    )
                    .tag(2)
                    SupportCheckPage(
                        showingManualFallback: showingManualFallback,
                        openAccessibilityShortcut: openAccessibilityShortcut,
                        foundAction: {
                            finish()
                            dismiss()
                        },
                        missingAction: {
                            markManualFallback()
                            showingManualFallback = true
                        }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                progress
            }
            .navigationTitle("Set up Buzzkill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .onAppear {
                showingManualFallback = shortcutSupport == .manualFallback
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
}

private struct OnboardingPage: View {
    let step: Int
    let title: String
    let detail: String
    let primaryTitle: String
    let primaryIcon: String
    let primaryAction: () -> Void
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
            Button(continueTitle, action: continueAction)
                .buttonStyle(.bordered)
                .tint(.primary)
        }
        .padding(28)
    }
}

private struct SupportCheckPage: View {
    let showingManualFallback: Bool
    let openAccessibilityShortcut: () -> Void
    let foundAction: () -> Void
    let missingAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("STEP 4 OF 4")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Image(systemName: showingManualFallback ? "hand.tap" : "checkmark.seal")
                .font(.system(size: 44, weight: .medium))
            Text(showingManualFallback ? "Use the quick fallback" : "Did you find the action?")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-0.7)
            Text(showingManualFallback
                ? "Set Color Filters as your Accessibility Shortcut. After that, a triple-click of the Side button toggles grayscale whenever you want it."
                : "In Shortcuts, search for Set Color Filters. If it appears, Buzzkill can work automatically.")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            if showingManualFallback {
                Button(action: openAccessibilityShortcut) {
                    Label("Open Accessibility Shortcut", systemImage: "hand.tap")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.black)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            } else {
                Button("Yes, I found it", action: foundAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                Button("No, it’s missing", action: missingAction)
                    .buttonStyle(.bordered)
                    .tint(.primary)
            }
        }
        .padding(28)
    }
}
