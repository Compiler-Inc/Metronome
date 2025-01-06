//
//  DLMTextInputView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import SwiftUI
import CompilerSwiftAI

struct DLMTextInputView: View {
    
    var model: DLMViewModel
    var process: (String) -> ()
    
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
                process(manualCommand)
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
            
            Button {
                model.startRealtimeTranscription()
            } label: {
                Text("Start TX")
            }
        }
        .padding()
    }
}

#Preview {
    let model = DLMViewModel()
    DLMTextInputView(model: model, process: { _ in })
}
