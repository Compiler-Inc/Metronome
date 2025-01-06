import SwiftUI
import CompilerSwiftAI

struct DLMView<AppState: Encodable & Sendable>: View {
    
    var state: AppState
    @State var model = DLMViewModel()
    var metronome: Metronome
    var deepgram: DeepgramService { model.deepgram }
    var dlm: DLMService
    var execute: ([DLMCommand<CommandArgs>]) -> ()
    
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
                if !model.manualCommand.isEmpty {
                    model.manualCommand += " "
                }
                model.manualCommand += transcript
            }
        }
        
        deepgram.onTranscriptionComplete = {
            Task { @MainActor in
                print("transcription complete")
            }
        }
    }
}
