import SwiftUI
import CompilerSwiftAI

struct DLMView<AppState: Encodable & Sendable>: View {
    
    var state: AppState
    var model = DLMViewModel()
    var metronome: Metronome
    var deepgram: DeepgramService { model.deepgram }
    var dlm: DLMService
    var execute: ([DLMCommand<CommandArgs>]) -> ()

    @State private var realtimeTranscript: String = ""
    @State private var realtimeTranscriptBuffer: String = ""
    @State private var isProcessingAudioCommands = false
    
    func process(prompt: String) {
        Task {
            model.addStep("Sending request to DLM")
            guard let commands: [DLMCommand<CommandArgs>] = try? await dlm.processCommand(prompt, for: state) else { return }
            model.completeLastStep()
            model.addStep("Executing commands")
            execute(commands)
            model.completeLastStep()
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            DLMTextInputView(model: model, process: process)
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
