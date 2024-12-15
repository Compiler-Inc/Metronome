import SwiftUI

struct DLMView: View {
    @Binding var metronome: Metronome
    @Binding var dlm: DLMService
    @Binding var realtimeTranscript: String
    @Binding var isProcessingAudioCommands: Bool

    var body: some View {
        VStack(spacing: 4) {
            // Text Input Area
            VStack(spacing: 8) {
                Text("Prompt")
                    .foregroundStyle(DLMColors.primary75)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: .init(
                        get: { dlm.manualCommand ?? "" },
                        set: { dlm.manualCommand = $0 }
                    ))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
                .frame(height: 100)
                .foregroundStyle(DLMColors.primary100)
                .scrollContentBackground(.hidden)
                .background(DLMColors.primary20)
                .cornerRadius(8)
                .tint(DLMColors.primary100)

                Button(action: {
                    Task {
                        guard let commands = try? await dlm.processCommand(dlm.manualCommand ?? "") else { return }
                        try await dlm.executeCommands(commands.function_calls, metronome: metronome)
                    }
                }) {
                    HStack {
                        Text("Submit")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(DLMColors.dlmGradient)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(dlm.manualCommand?.isEmpty ?? true)
                .buttonStyle(.plain)
            }
            .padding()

            // Processing Steps Area
            VStack(alignment: .leading, spacing: 4) {
                if !dlm.processingSteps.isEmpty {
                Text("DLM Output")
                    .foregroundColor(DLMColors.primary75)
                        .font(.caption)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(dlm.processingSteps) { step in
                            HStack {
                                Text(step.text)
                                    .foregroundColor(DLMColors.primary75)

                                Spacer()

                                if step.isComplete {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .frame(width: 200)
        .background(DLMColors.primary10)
    }
}
