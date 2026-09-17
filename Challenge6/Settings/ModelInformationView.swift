import SwiftUI

struct ModelInformationView: View {
    private let sourceURL = URL(string: "https://archive.ics.uci.edu/dataset/228/sms%2Bspam%2Bcollection")!

    var body: some View {
        List {
            Section("Active Model") {
                LabeledContent("Name", value: ModelMetadata.coreMLMaxEnt.displayName)
                LabeledContent("Identifier", value: ModelMetadata.coreMLMaxEnt.identifier)
                LabeledContent("Version", value: ModelMetadata.coreMLMaxEnt.version)
                LabeledContent("Algorithm", value: "Create ML MaxEnt")
                LabeledContent("Runtime", value: "Natural Language")
                LabeledContent("Language", value: "English")
                Label("On-device inference", systemImage: "checkmark.shield")
            }

            Section("Training Data") {
                Text("The model was trained from the public UCI SMS Spam Collection: 5,574 labeled English SMS messages collected by Almeida and Hidalgo. Original “spam” and “ham” labels were mapped to “suspicious” and “legitimate.”")

                Link(destination: sourceURL) {
                    Label("View UCI Dataset Source", systemImage: "arrow.up.right.square")
                }

                LabeledContent("License", value: "CC BY 4.0")
                Text("Almeida, T. & Hidalgo, J. (2011). SMS Spam Collection. DOI: 10.24432/C5CC84.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Privacy") {
                Text("Input is processed locally. The app has no cloud sync and no analytics. If history saving is enabled, normalized message text and its result are stored locally, with a maximum of 50 records.")
            }

            Section("Known Limitations") {
                Text("The corpus is older, English-focused, and reflects the language and collection context of its time. It does not cover every modern scam or communication style.")
                Text("High benchmark accuracy on one dataset does not make this a production security system. Confidence is a model score, not certainty.")
                Text("This app is an educational demonstration, not professional safety advice or a substitute for independent verification and official reporting channels.")
            }

            Section("Why Naive Bayes Remains") {
                Text("The hand-written Multinomial Naive Bayes classifier remains in the project as an inspectable learning baseline for tokenization, word counts, priors, smoothing, and log-probability scoring. It is not a silent runtime fallback.")
            }
        }
        .frame(maxWidth: AppSpacing.readableContentWidth)
        .frame(maxWidth: .infinity)
        .navigationTitle("Model Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}
