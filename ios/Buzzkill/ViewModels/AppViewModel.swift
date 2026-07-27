import Foundation
import UIKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var didFinishAutomation = false {
        didSet { defaults.set(didFinishAutomation, forKey: Keys.didFinishAutomation) }
    }
    @Published private(set) var openedShortcutInstallers: Set<BundledShortcut> {
        didSet {
            for shortcut in BundledShortcut.allCases {
                defaults.set(
                    openedShortcutInstallers.contains(shortcut),
                    forKey: Keys.openedInstaller(for: shortcut)
                )
            }
        }
    }
    @Published private(set) var didVerifyShortcuts: Bool {
        didSet { defaults.set(didVerifyShortcuts, forKey: Keys.didVerifyShortcuts) }
    }
    @Published private(set) var shortcutTestPhase: ShortcutTestPhase
    @Published private(set) var isGrayscaleEnabled = false
    @Published private(set) var statusMessage = "Checking your display setting…"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        didFinishAutomation = defaults.bool(forKey: Keys.didFinishAutomation)
        openedShortcutInstallers = Set(
            BundledShortcut.allCases.filter {
                defaults.bool(forKey: Keys.openedInstaller(for: $0))
            }
        )
        let shortcutsVerified = defaults.bool(forKey: Keys.didVerifyShortcuts)
        didVerifyShortcuts = shortcutsVerified
        shortcutTestPhase = shortcutsVerified ? .verified : .ready
        refreshGrayscaleStatus()
    }

    func refreshGrayscaleStatus() {
        isGrayscaleEnabled = UIAccessibility.isGrayscaleEnabled
        statusMessage = isGrayscaleEnabled
            ? "Grayscale is on across your iPhone."
            : "Grayscale is off. The automations will switch it when your chosen apps open and close."
    }

    func openAutomationCreator() {
        guard let url = URL(string: "shortcuts://") else { return }
        UIApplication.shared.open(url) { [weak self] opened in
            guard !opened else { return }
            Task { @MainActor in
                self?.statusMessage = "Open the Shortcuts app manually to finish setup."
            }
        }
    }

    func openSystemSettings() {
        let destinations = [
            "settings-navigation://com.apple.Settings.Accessibility/DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR#GRAYSCALE",
            "App-Prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR",
            "App-Prefs:"
        ]
        openFirstAvailableSettingsDestination(destinations)
    }

    func installShortcut(_ shortcut: BundledShortcut) {
        guard let fileURL = bundledShortcutURL(for: shortcut) else {
            statusMessage = "Buzzkill couldn’t find the \(shortcut.displayName) installer."
            return
        }

        UIApplication.shared.open(fileURL) { [weak self] opened in
            Task { @MainActor in
                guard let self else { return }
                if opened {
                    self.openedShortcutInstallers.insert(shortcut)
                } else {
                    self.statusMessage = "Couldn’t open \(shortcut.displayName). Try reinstalling Buzzkill."
                }
            }
        }
    }

    private func openFirstAvailableSettingsDestination(
        _ destinations: [String],
        index: Int = 0
    ) {
        guard destinations.indices.contains(index),
              let url = URL(string: destinations[index]) else {
            statusMessage = "Open Settings → Accessibility → Display & Text Size → Color Filters."
            return
        }

        UIApplication.shared.open(url) { [weak self] opened in
            guard !opened else { return }
            Task { @MainActor in
                self?.openFirstAvailableSettingsDestination(
                    destinations,
                    index: index + 1
                )
            }
        }
    }

    func testShortcut(_ shortcut: BundledShortcut) {
        guard let url = shortcutCallbackURL(for: shortcut) else {
            shortcutTestPhase = .failed(.couldNotOpen(shortcut))
            return
        }

        shortcutTestPhase = .running(shortcut)
        UIApplication.shared.open(url) { [weak self] opened in
            guard !opened else { return }
            Task { @MainActor in
                self?.shortcutTestPhase = .failed(.couldNotOpen(shortcut))
            }
        }
    }

    func handleShortcutCallback(_ url: URL) {
        guard url.scheme == "buzzkill",
              url.host == "shortcut",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let mode = components.queryItems?.first(where: { $0.name == "mode" })?.value,
              let shortcut = BundledShortcut(callbackValue: mode)
        else { return }

        switch url.path {
        case "/success":
            verifyShortcutResult(shortcut)
        case "/cancel":
            shortcutTestPhase = .failed(.cancelled(shortcut))
        case "/error":
            shortcutTestPhase = .failed(.couldNotRun(shortcut))
        default:
            break
        }
    }

    func resetSetupProgress() {
        didFinishAutomation = false
        openedShortcutInstallers = []
        didVerifyShortcuts = false
        shortcutTestPhase = .ready
        refreshGrayscaleStatus()
    }

    private func bundledShortcutURL(for shortcut: BundledShortcut) -> URL? {
        Bundle.main.url(
            forResource: shortcut.resourceName,
            withExtension: "shortcut",
            subdirectory: "Shortcuts"
        ) ?? Bundle.main.url(
            forResource: shortcut.resourceName,
            withExtension: "shortcut"
        )
    }

    private func shortcutCallbackURL(for shortcut: BundledShortcut) -> URL? {
        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "x-callback-url"
        components.path = "/run-shortcut"
        components.queryItems = [
            URLQueryItem(name: "name", value: shortcut.displayName),
            URLQueryItem(
                name: "x-success",
                value: "buzzkill://shortcut/success?mode=\(shortcut.callbackValue)"
            ),
            URLQueryItem(
                name: "x-cancel",
                value: "buzzkill://shortcut/cancel?mode=\(shortcut.callbackValue)"
            ),
            URLQueryItem(
                name: "x-error",
                value: "buzzkill://shortcut/error?mode=\(shortcut.callbackValue)"
            )
        ]
        return components.url
    }

    private func verifyShortcutResult(_ shortcut: BundledShortcut) {
        refreshGrayscaleStatus()

        switch shortcut {
        case .grayscaleOn where isGrayscaleEnabled:
            shortcutTestPhase = .onVerified
        case .grayscaleOn:
            shortcutTestPhase = .failed(.filterIsNotGrayscale)
        case .grayscaleOff where !isGrayscaleEnabled:
            didVerifyShortcuts = true
            shortcutTestPhase = .verified
        case .grayscaleOff:
            shortcutTestPhase = .failed(.colorWasNotRestored)
        }
    }

}

private enum Keys {
    static let didFinishAutomation = "didFinishAutomation"
    static let didVerifyShortcuts = "didVerifyShortcuts"

    static func openedInstaller(for shortcut: BundledShortcut) -> String {
        "openedInstaller.\(shortcut.rawValue)"
    }
}

enum BundledShortcut: String, CaseIterable, Identifiable {
    case grayscaleOn
    case grayscaleOff

    var id: Self { self }

    var displayName: String {
        switch self {
        case .grayscaleOn: "Buzzkill On"
        case .grayscaleOff: "Buzzkill Off"
        }
    }

    var resourceName: String { displayName }

    var callbackValue: String { rawValue }

    init?(callbackValue: String) {
        self.init(rawValue: callbackValue)
    }
}

enum ShortcutTestPhase: Equatable {
    case ready
    case running(BundledShortcut)
    case onVerified
    case verified
    case failed(ShortcutTestFailure)
}

enum ShortcutTestFailure: Equatable {
    case couldNotOpen(BundledShortcut)
    case couldNotRun(BundledShortcut)
    case cancelled(BundledShortcut)
    case filterIsNotGrayscale
    case colorWasNotRestored
}
