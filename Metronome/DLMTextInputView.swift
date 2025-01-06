//
//  DLMTextInputView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import SwiftUI
import CompilerSwiftAI

struct DLMTextInputView: View {
    
    var state: CurrentState
    var executeCommands: ([DLMCommand<CommandArgs>]) -> ()
    var dlm: DLMService
    
    @State var manualCommand = ""
    
    var body: some View {
        // Text Input Area
        VStack(spacing: 8) {
            Text("Prompt")
                .foregroundStyle(DLMColors.primary75)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $manualCommand)
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
                    // metronome.addStep("Sending request to DLM")
                    guard let commands: [DLMCommand<CommandArgs>] = try? await dlm.processCommand(manualCommand, for: state) else { return }
                    // metronome.completeLastStep()
                    executeCommands(commands)
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
            .disabled(manualCommand.isEmpty)
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    let metronome = Metronome()
    DLMTextInputView(state: CurrentState(bpm: metronome.tempo),
                     executeCommands: metronome.executeCommands,
                     dlm: DLMService(apiKey: "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1",
                                     appId: "1561de0c-8e1c-4ace-a870-ac0baecf40f6"))
}
