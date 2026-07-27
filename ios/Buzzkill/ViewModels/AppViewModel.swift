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

}

private enum Keys {
    static let didFinishAutomation = "didFinishAutomation"
}
