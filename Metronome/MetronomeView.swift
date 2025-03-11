//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import Transcriber

struct MetronomeView: View {
    // Customizable light color
    @State private var lightColor = Color.red
    @State private var viewModel: MetronomeViewModel
        
    init(compiler: CompilerManager) {
        _viewModel = State(initialValue: MetronomeViewModel(compiler: compiler))
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                // Play/Stop button
                Button(action: {
                    viewModel.metronome.togglePlayback()
                }) {
                    Image(systemName: viewModel.metronome.isPlaying ? "stop.fill" : "play.fill")
                        .foregroundColor(lightColor.opacity(0.8))
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
                lightColor: lightColor,
                timeSignatureTop: viewModel.metronome.timeSignatureTop,
                currentBeat: viewModel.metronome.currentBeat
            )
            
            Spacer()
            
                       
            // Replace the SpeechButton with the InputSwitcherView
            InputSwitcherView(viewModel: viewModel, lightColor: lightColor)
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
