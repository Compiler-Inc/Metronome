//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import Transcriber

struct InputSwitcherView: View {
    var viewModel: MetronomeViewModel
    let lightColor: Color
    @State private var functionPrompt: String = ""
    @State private var bpmPrompt: String = ""
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Speech button view
            VStack {
                SpeechButton(
                    isRecording: viewModel.transcriber.isRecording,
                    rmsValue: viewModel.transcriber.rmsValue,
                    isProcessing: viewModel.isProcessingPrompt,
                    supportsThinkingState: true,
                    colors: .init(idle: lightColor, thinking: .gray),
                    onTap: {
                        Task {
                            await viewModel.toggleTranscription()
                        }
                    }
                )
                .padding(4)
                
                
                // Show "Swipe for Type →" when on speech button
                HStack(spacing: 4) {
                    Spacer()
                    
                    Text("Swipe for Type")
                        .font(.system(size: 10))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9))
                }
                .foregroundColor(.secondary)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            }
            
            VStack {
                // Text input view - pass isProcessingPrompt to handle thinking state
                TextInputView(
                    promptText: $functionPrompt,
                    onSend: {
                        Task {
                            await viewModel.processFunctionPrompt(functionPrompt)
                            functionPrompt = ""
                        }
                    },
                    isProcessing: viewModel.isProcessingPrompt
                )
                .padding(.bottom, 8)
                
                // Show "← Swipe for Voice" when on text input
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9))
                    Text("Swipe for Voice")
                        .font(.system(size: 10))
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.leading, 16)
                .padding(.bottom, 8)
            }
            
            VStack {
                // Text input view - pass isProcessingPrompt to handle thinking state
                TextInputView(
                    promptText: $bpmPrompt,
                    onSend: {
                        Task {
                            await viewModel.processModelPrompt(bpmPrompt)
                            bpmPrompt = ""
                        }
                    },
                    isProcessing: viewModel.isProcessingPrompt
                )
                .padding(.bottom, 8)
                
                // Show "← Swipe for Voice" when on text input
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9))
                    Text("Swipe for Voice")
                        .font(.system(size: 10))
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.leading, 16)
                .padding(.bottom, 8)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 100)
    }
}

#Preview {
    InputSwitcherView(viewModel: .init(compiler: .init()), lightColor: .red)
}
