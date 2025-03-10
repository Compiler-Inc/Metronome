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
                    Text("\(Int(metronome.data.tempo))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(width: 100)
                }
                
                LabeledContent("Target Tempo", value: "\(metronome.data.targetTempo ?? metronome.data.tempo)")
                
                LabeledContent("Duration", value: "\(metronome.data.targetDuration ?? 0)")
                
                LabeledContent("Pulse", value: "\(GiantSound(rawValue: Int(metronome.data.note)) ?? .snap)")
                LabeledContent("Downbeat", value: "\(GiantSound(rawValue: Int(metronome.data.startingNote ?? 0)) ?? .none)")
                LabeledContent("Upbeat", value: "\(GiantSound(rawValue: Int(metronome.data.accentNote ?? 0)) ?? .none)")
                    .monospacedDigit()
                LabeledContent("Gap Measures", value: "\(metronome.data.gapMeasureCount)")
                Button(action: {
                    metronome.data.isPlaying.toggle()
                }) {
                    Image(systemName: metronome.data.isPlaying ? "stop" : "play")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(metronome.data.isPlaying ? .red : .green)
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
