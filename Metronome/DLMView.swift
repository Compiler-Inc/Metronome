import SwiftUI
import CompilerSwiftAI

struct DLMView: View {
    var metronome: Metronome
    var deepgram: DeepgramService { metronome.deepgram }
    @State var dlm = DLMService(apiKey: "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1",
                                appId: "1561de0c-8e1c-4ace-a870-ac0baecf40f6")

    @State private var audioFileTranscript: String = ""
    @State private var promptTranscript: String = ""
    @State private var dlmResponse: String = ""
    @State private var isProcessingDLM = false
    @State private var realtimeTranscript: String = ""
    @State private var realtimeTranscriptBuffer: String = ""
    @State private var isProcessingAudioCommands = false
    @State private var processingSteps: [String] = []

    var body: some View {
        VStack(spacing: 4) {
            
            DLMTextInputView(metronome: metronome, dlm: dlm)

            // Processing Steps Area
            VStack(alignment: .leading, spacing: 4) {
                if !metronome.processingSteps.isEmpty {
                Text("DLM Output")
                    .foregroundColor(DLMColors.primary75)
                        .font(.caption)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(metronome.processingSteps) { step in
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
        .onAppear {
            setupTranscriptionHandlers()
        }
    }
    
    private func setupTranscriptionHandlers() {
        
        deepgram.onTranscriptReceived = { transcript in
            Task { @MainActor in
                if !realtimeTranscriptBuffer.isEmpty {
                    realtimeTranscriptBuffer += " "
                }
                realtimeTranscriptBuffer += transcript
                realtimeTranscript = realtimeTranscriptBuffer
            }
        }
        
        deepgram.onTranscriptionComplete = {
            Task { @MainActor in
                isProcessingAudioCommands = true
                
                do {
                    guard realtimeTranscript != "" else { return }
                    let response: [DLMCommand<CommandArgs>] = try await dlm.processCommand(realtimeTranscript, for: CurrentState(bpm: metronome.tempo))
                    metronome.executeCommands(response)
                    guard let commands: [DLMCommand<CommandArgs>] = try? await dlm.processCommand(realtimeTranscriptBuffer, for: CurrentState(bpm: metronome.tempo)) else { return }
                    metronome.executeCommands(commands)
                    realtimeTranscript = ""
                    realtimeTranscriptBuffer = ""
                } catch {
                    metronome.processingSteps.append(ProcessingStep(text: "Error: \(error.localizedDescription)", isComplete: true))
                }
                isProcessingAudioCommands = false
            }
        }
    }
}
