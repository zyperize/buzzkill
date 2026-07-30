import SwiftUI

struct OnboardingView: View {
    let canClose: Bool
    let onClose: () -> Void
    let onStartSetup: () -> Void

    @AppStorage("onboarding.socialMediaTime") private var socialMediaTime = ""
    @AppStorage("onboarding.primaryPull") private var primaryPull = ""
    @State private var page: OnboardingPage

    init(
        canClose: Bool,
        onClose: @escaping () -> Void,
        onStartSetup: @escaping () -> Void
    ) {
        self.canClose = canClose
        self.onClose = onClose
        self.onStartSetup = onStartSetup
        _page = State(initialValue: Self.debugInitialPage)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $page) {
                ForEach(OnboardingPage.allCases) { onboardingPage in
                    pageContent(onboardingPage)
                        .tag(onboardingPage)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            footer
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var header: some View {
        HStack {
            Text("BUZZKILL")
                .font(.caption.weight(.black))
                .tracking(1.2)
            Spacer()
            if canClose {
                Button("Close", action: onClose)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    @ViewBuilder
    private func pageContent(_ onboardingPage: OnboardingPage) -> some View {
        switch onboardingPage {
        case .welcome:
            OnboardingStoryPage(
                imageName: "OnboardingWelcome",
                eyebrow: "HELLO THERE",
                title: "Welcome to Buzzkill!",
                detail: "Social media, with the color turned down. Buzzkill makes selected feeds less visually rewarding without locking you out."
            )
        case .purpose:
            OnboardingStoryPage(
                imageName: "OnboardingDullFeed",
                eyebrow: "THE IDEA",
                title: "Make the feed less rewarding",
                detail: "Buzzkill turns selected apps grayscale while they’re open. Everything still works. It just stops looking like a tiny casino in your hand."
            )
        case .color:
            OnboardingStoryPage(
                imageName: "OnboardingColorHook",
                eyebrow: "WHY GRAYSCALE?",
                title: "Color is part of the hook",
                detail: "Colorful, reward-linked cues can pull attention. A peer-reviewed experiment found that grayscale reduced reported smartphone use and made phones feel less attractive.",
                researchURL: URL(string: "https://doi.org/10.1016/j.chbr.2023.100294")
            )
        case .choice:
            OnboardingStoryPage(
                imageName: "OnboardingChoice",
                eyebrow: "NO SHAME REQUIRED",
                title: "Not another punishment",
                detail: "Blocking an app can turn one slip into failure. Buzzkill leaves the door open and lets the feed make its own case. Without the shine, scrolling often looks as pointless as it feels."
            )
        case .privacy:
            OnboardingStoryPage(
                imageName: "OnboardingPrivacy",
                eyebrow: "PRIVATE BY DESIGN",
                title: "Your phone stays yours",
                detail: "Buzzkill uses Apple’s Shortcuts and Accessibility features on your iPhone. No account, VPN, or screen recording—and Buzzkill never reads what you do inside another app."
            )
        case .reflection:
            OnboardingReflectionPage(
                socialMediaTime: $socialMediaTime,
                primaryPull: $primaryPull
            )
        case .setup:
            OnboardingStoryPage(
                imageName: "OnboardingSetup",
                eyebrow: "ONE LAST THING",
                title: "A little setup. A duller feed.",
                detail: "Apple makes us connect two Shortcuts automations once: one when selected apps open and one when they close. It takes a few minutes. Then Buzzkill gets out of the way."
            )
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            HStack(spacing: 7) {
                ForEach(OnboardingPage.allCases) { onboardingPage in
                    Capsule()
                        .fill(onboardingPage == page ? Color.primary : Color.secondary.opacity(0.25))
                        .frame(width: onboardingPage == page ? 28 : 8, height: 8)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: page)
            .accessibilityLabel("Onboarding page \(page.rawValue + 1) of \(OnboardingPage.allCases.count)")

            HStack(spacing: 12) {
                if page != .welcome {
                    Button(action: previousPage) {
                        Text("Back")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }

                Button(action: continueAction) {
                    Text(page == .setup ? "Set up Buzzkill" : "Continue")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color(uiColor: .systemBackground))
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    private func previousPage() {
        guard let previous = OnboardingPage(rawValue: page.rawValue - 1) else { return }
        withAnimation { page = previous }
    }

    private func continueAction() {
        guard page != .setup else {
            onStartSetup()
            return
        }
        guard let next = OnboardingPage(rawValue: page.rawValue + 1) else { return }
        withAnimation { page = next }
    }

    private static var debugInitialPage: OnboardingPage {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "--onboarding-page"),
              arguments.indices.contains(flagIndex + 1),
              let rawValue = Int(arguments[flagIndex + 1]),
              let page = OnboardingPage(rawValue: rawValue)
        else {
            return .welcome
        }
        return page
        #else
        return .welcome
        #endif
    }
}

private struct OnboardingStoryPage: View {
    let imageName: String
    let eyebrow: String
    let title: String
    let detail: String
    var researchURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .accessibilityHidden(true)

                Text(eyebrow)
                    .font(.caption.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let researchURL {
                    Link(destination: researchURL) {
                        Label("Read the peer-reviewed study", systemImage: "arrow.up.right")
                            .font(.footnote.weight(.semibold))
                    }
                    .tint(.primary)
                    .accessibilityHint("Opens the study in your browser")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
        }
    }
}

private struct OnboardingReflectionPage: View {
    @Binding var socialMediaTime: String
    @Binding var primaryPull: String

    private let timeOptions = [
        "Less than 1 hour",
        "1–2 hours",
        "2–4 hours",
        "4+ hours"
    ]
    private let pullOptions = [
        "Habit",
        "Boredom",
        "FOMO",
        "Visual rewards"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image("OnboardingReflection")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 190)
                    .accessibilityHidden(true)

                Text("A QUICK REALITY CHECK")
                    .font(.caption.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text("How does scrolling fit into your day?")
                    .font(.system(.title, design: .rounded, weight: .bold))

                OnboardingQuestion(
                    title: "How long do you spend scrolling on a typical day?",
                    options: timeOptions,
                    selection: $socialMediaTime
                )

                OnboardingQuestion(
                    title: "What usually pulls you back?",
                    options: pullOptions,
                    selection: $primaryPull
                )

                Label(
                    "These answers stay on this iPhone and are only for your own reflection.",
                    systemImage: "lock.fill"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
        }
    }
}

private struct OnboardingQuestion: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack(spacing: 8) {
                            Text(option)
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                        .padding(.horizontal, 12)
                        .foregroundStyle(
                            selection == option
                                ? Color(uiColor: .systemBackground)
                                : Color.primary
                        )
                        .background(
                            selection == option
                                ? Color.primary
                                : Color.primary.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == option ? .isSelected : [])
                }
            }
        }
    }
}

private enum OnboardingPage: Int, CaseIterable, Identifiable {
    case welcome
    case purpose
    case color
    case choice
    case privacy
    case reflection
    case setup

    var id: Self { self }
}
