import SwiftUI

struct ResearchView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    intro
                    ForEach(Study.all) { study in
                        StudyCard(study: study)
                    }
                    caveat
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("The research")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WHY GRAYSCALE?")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Text("What the studies say")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
            Text("Buzzkill did not run these studies and is not affiliated with their authors. Each link opens the published paper so you can read it yourself.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var caveat: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("What this does not show", systemImage: "exclamationmark.circle")
                .font(.headline)
            Text("These studies report averages across groups, not what will happen to you. Results differ between people and between studies, and some findings are mixed. Zimmermann and Sobolev found that cutting screen time did not by itself improve well-being or academic performance. Dekker and Baumgartner found grayscale did not change how often people unlocked their phones.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Buzzkill is not a medical device and promises no particular outcome.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            Color.primary.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

private struct StudyCard: View {
    let study: Study

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(study.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(study.authors) · \(study.journal), \(study.year)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(study.finding)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Link(destination: study.url) {
                Label("Read the paper", systemImage: "arrow.up.right")
                    .font(.footnote.weight(.semibold))
            }
            .tint(.primary)
            .accessibilityHint("Opens the published paper in your browser")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            Color.primary.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

struct Study: Identifiable {
    let id = UUID()
    let title: String
    let authors: String
    let journal: String
    let year: String
    let finding: String
    let url: URL

    // Every entry below was checked against the publisher's own record.
    // Keep the finding lines to what each paper reports; do not extrapolate.
    static let all: [Study] = [
        Study(
            title: "True colors: Grayscale setting reduces screen time in college students",
            authors: "Holte & Ferraro",
            journal: "The Social Science Journal",
            year: "2020",
            finding: "College students whose phones were switched to grayscale recorded less daily screen time than those who kept color.",
            url: URL(string: "https://doi.org/10.1080/03623319.2020.1737461")!
        ),
        Study(
            title: "Color me calm: Grayscale phone setting reduces anxiety and problematic smartphone use",
            authors: "Holte, Giesen & Ferraro",
            journal: "Current Psychology",
            year: "2021",
            finding: "A follow-up from the same group reporting lower anxiety and lower problematic smartphone use under a grayscale setting.",
            url: URL(string: "https://doi.org/10.1007/s12144-021-02020-y")!
        ),
        Study(
            title: "Digital Strategies for Screen Time Reduction: A Randomized Field Experiment",
            authors: "Zimmermann & Sobolev",
            journal: "Cyberpsychology, Behavior, and Social Networking",
            year: "2023",
            finding: "In a pre-registered field experiment with 112 people, grayscale produced an immediate, significant drop in measured screen time. The authors found no immediate causal effect of that reduction on well-being or academic performance.",
            url: URL(string: "https://doi.org/10.1089/cyber.2022.0027")!
        ),
        Study(
            title: "Suffering from problematic smartphone use? Why not use grayscale setting as an intervention!",
            authors: "Wickord & Quaiser-Pohl",
            journal: "Computers in Human Behavior Reports",
            year: "2023",
            finding: "An experimental study reporting that a grayscale setting decreases usage time, alongside a positive correlation between problematic smartphone use, usage duration, and perceived suffering.",
            url: URL(string: "https://doi.org/10.1016/j.chbr.2023.100294")!
        ),
        Study(
            title: "Is life brighter when your phone is not? The efficacy of a grayscale smartphone intervention addressing digital well-being",
            authors: "Dekker & Baumgartner",
            journal: "Mobile Media & Communication",
            year: "2024",
            finding: "Tracking 84 people for two weeks, daily screen time fell by about 20 minutes and perceived control improved. The number of phone unlocks did not change, and productivity and sleep quality were unaffected.",
            url: URL(string: "https://doi.org/10.1177/20501579231212062")!
        ),
        Study(
            title: "A cross-over feasibility trial of smartphone grayscale mode in medical students",
            authors: "Hagerty et al.",
            journal: "Frontiers in Digital Health",
            year: "2026",
            finding: "In a cross-over trial with 51 medical students, grayscale mode was associated with a statistically significant reduction in mean daily screen time of about 28 minutes.",
            url: URL(string: "https://doi.org/10.3389/fdgth.2026.1816095")!
        )
    ]
}
