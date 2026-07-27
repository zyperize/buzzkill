import Foundation
import UIKit

@MainActor
final class AppViewModel: ObservableObject {
    @Published var didFinishAutomation = false {
        didSet { defaults.set(didFinishAutomation, forKey: Keys.didFinishAutomation) }
    }
    @Published private(set) var isGrayscaleEnabled = false
    @Published private(set) var statusMessage = "Checking your display setting…"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        didFinishAutomation = defaults.bool(forKey: Keys.didFinishAutomation)
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

    func installShortcut(_ shortcut: BundledShortcut) {
        guard let fileURL = bundledShortcutURL(for: shortcut) else {
            statusMessage = "Buzzkill couldn’t find the \(shortcut.displayName) installer."
            return
        }

        UIApplication.shared.open(fileURL) { [weak self] opened in
            guard !opened else { return }
            Task { @MainActor in
                self?.statusMessage = "Couldn’t open \(shortcut.displayName). Try reinstalling Buzzkill."
            }
        }
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

}

private enum Keys {
    static let didFinishAutomation = "didFinishAutomation"
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
}
