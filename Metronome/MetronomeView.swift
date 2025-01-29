//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct MetronomeView: View {
    
    var metronome: Metronome
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(.clear)
            
            Form {
                
                LabeledContent("Tempo") {
                    Text("\(Int(metronome.tempo))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(width: 100)
                }
                
                LabeledContent("Target Tempo", value: "\(metronome.targetTempo ?? metronome.tempo)")
                
                LabeledContent("Duration", value: "\(metronome.targetDuration ?? 0)")
                
                LabeledContent("Pulse", value: "\(GiantSound(rawValue: Int(metronome.note)) ?? .snap)")
                LabeledContent("Downbeat", value: "\(GiantSound(rawValue: Int(metronome.startingNote ?? 0)) ?? .none)")
                LabeledContent("Upbeat", value: "\(GiantSound(rawValue: Int(metronome.accentNote ?? 0)) ?? .none)")
                    .monospacedDigit()
                LabeledContent("Gap Measures", value: "\(metronome.gapMeasureCount)")
                Button(action: {
                    metronome.isPlaying.toggle()
                }) {
                    Image(systemName: metronome.isPlaying ? "stop" : "play")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(metronome.isPlaying ? .red : .green)
                }
            }
        }
    }
}

#Preview {
    MetronomeView(metronome: Metronome())
        .buttonStyle(.borderless)
        .padding()
}
