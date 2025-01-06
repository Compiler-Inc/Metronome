//
//  MetronomeView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import SwiftUI

struct MetronomeView: View {
    
    var metronome: Metronome
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(.clear)
            
            VStack {
                
                Button {
                    metronome.startRealtimeTranscription()
                } label: {
                    Text("Start TX")
                }
                
                HStack {
                    Button(action: {
                        metronome.tempo -= 10.0
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    
                    Text("\(Int(metronome.tempo))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(width: 100)
                    
                    Button(action: {
                        metronome.tempo += 10.0
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                VStack(spacing: 15) {
                    // LabeledContent("Pulse", value: "\(GiantSound(rawValue: Int(metronome.note)) ?? .snap)")
                    Text("Pulse: \(GiantSound(rawValue: Int(metronome.note)) ?? .snap)")
                        .monospacedDigit()
                    Text("Downbeat: \(GiantSound(rawValue: Int(metronome.startingNote ?? 0)) ?? .none)")
                        .monospacedDigit()
                    Text("Upbeat: \(GiantSound(rawValue: Int(metronome.accentNote ?? 0)) ?? .none)")
                        .monospacedDigit()
                    Text("Gap Measures: \(metronome.gapMeasureCount)")
                        .monospacedDigit()
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
            .padding()
        }
    }
}

#Preview {
    MetronomeView(metronome: Metronome())
        .buttonStyle(.borderless)
        .padding()
}
