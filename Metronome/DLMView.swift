import SwiftUI
import CompilerSwiftAI

struct DLMView: View {
    
    var model = DLMViewModel()
    var metronome: Metronome
    var deepgram: DeepgramService { metronome.deepgram }
    var dlm: DLMService

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
            DLMTextInputView(state: CurrentState(bpm: metronome.tempo),
                             executeCommands: metronome.executeCommands,
                             dlm: dlm)
            DLMProcessingStepsView(model: model)
        }
        .frame(minWidth: 200)
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
