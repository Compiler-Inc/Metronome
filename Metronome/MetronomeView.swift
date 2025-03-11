//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import Transcriber

struct MetronomeView: View {
    @State private var viewModel: MetronomeViewModel
        
    init(compiler: CompilerManager) {
        _viewModel = State(initialValue: MetronomeViewModel(compiler: compiler))
    }
    
    var inputView: some View {
        InputSwitcherView(viewModel: viewModel, lightColor: viewModel.metronome.color)
    }

    var body: some View {
        ZStack {
            if viewModel.showFunctionNotification && !viewModel.functionDescriptions.isEmpty {
                VStack {
                    Spacer()
                    
                    FunctionNotificationView(descriptions: viewModel.functionDescriptions)
                        .animation(.spring(), value: viewModel.showFunctionNotification)
                    
                    // Replace the SpeechButton with the InputSwitcherView
                    inputView
                        .opacity(0)
                }
            }
            VStack {
                HStack {
                    Spacer()
                    
                    // Play/Stop button
                    Button(action: {
                        viewModel.metronome.togglePlayback()
                    }) {
                        Image(systemName: viewModel.metronome.isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(viewModel.metronome.color.opacity(0.8))
                    }
                    .padding(.trailing, 8)
                    
                    Text("\(Int(viewModel.metronome.tempo))")
                        .font(.system(size: 38))
                        .fontWeight(.light)
                        .opacity(0.4)
                }
                
                Spacer()
                
                // Beat indicators/lights
                BeatsView(
                    lightColor: viewModel.metronome.color,
                    timeSignatureTop: viewModel.metronome.timeSignatureTop,
                    currentBeat: viewModel.metronome.currentBeat
                )
                
                Spacer()
                
                inputView
            }
        }
        .padding()
        .onAppear {
            viewModel.metronome.start()
            Task {
                try await viewModel.transcriber.requestAuthorization()
            }
        }
        .onDisappear {
            viewModel.metronome.stop()
        }
    }
}

#Preview("Metronome View") {
    MetronomeView(compiler: CompilerManager())
}
