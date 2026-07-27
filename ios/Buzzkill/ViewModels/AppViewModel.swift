import Foundation
import UIKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var didFinishAutomation = false {
        didSet { defaults.set(didFinishAutomation, forKey: Keys.didFinishAutomation) }
    }
    @Published var shortcutSupport: ShortcutSupport {
        didSet { defaults.set(shortcutSupport.rawValue, forKey: Keys.shortcutSupport) }
    }
    @Published private(set) var isGrayscaleEnabled = false
    @Published private(set) var statusMessage = "Checking your display setting…"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        didFinishAutomation = defaults.bool(forKey: Keys.didFinishAutomation)
        shortcutSupport = ShortcutSupport(rawValue: defaults.string(forKey: Keys.shortcutSupport) ?? "") ?? .unknown
        refreshGrayscaleStatus()
    }

    func refreshGrayscaleStatus() {
        isGrayscaleEnabled = UIAccessibility.isGrayscaleEnabled
        if shortcutSupport == .manualFallback {
            statusMessage = "This iPhone doesn’t expose Set Color Filters in Shortcuts. Use the manual Accessibility Shortcut instead."
        } else {
            statusMessage = isGrayscaleEnabled
                ? "Grayscale is on across your iPhone."
                : "Grayscale is off. Confirm that Shortcuts offers Set Color Filters before relying on automation."
        }
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

    func openColorFiltersSettings() {
        openPrivateSettingsURL(
            "settings-navigation://com.apple.Settings.Accessibility/DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR#GRAYSCALE",
            fallback: "App-prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR#FILTER_COLOR_ENABLED"
        )
    }

    func openAccessibilityShortcutSettings() {
        openPrivateSettingsURL(
            "settings-navigation://com.apple.Settings.Accessibility/TRIPLE_CLICK_TITLE",
            fallback: "App-prefs:root=ACCESSIBILITY&path=TRIPLE_CLICK_TITLE"
        )
    }

    private func openPrivateSettingsURL(_ primary: String, fallback: String) {
        guard let primaryURL = URL(string: primary) else { return }
        UIApplication.shared.open(primaryURL) { [weak self] opened in
            guard !opened, let fallbackURL = URL(string: fallback) else {
                if !opened {
                    self?.statusMessage = "Couldn’t open Color Filters. Open Settings and try again."
                }
                return
            }
            UIApplication.shared.open(fallbackURL)
        }
    }

}

private enum Keys {
    static let didFinishAutomation = "didFinishAutomation"
    static let shortcutSupport = "shortcutSupport"
}

enum ShortcutSupport: String {
    case unknown
    case setColorFiltersAvailable
    case manualFallback
}
