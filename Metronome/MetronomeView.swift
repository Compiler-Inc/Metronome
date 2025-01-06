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
                
                VStack(spacing: 30) {
                    Text("Pulse: \(GiantSound(rawValue: Int(metronome.note)) ?? .snap) (\(metronome.note))")
                        .monospacedDigit()
                    Text("Downbeat: \(GiantSound(rawValue: Int(metronome.startingNote ?? 0)) ?? .none) (\(metronome.startingNote ?? 0))")
                        .monospacedDigit()
                    Text("Upbeat: \(GiantSound(rawValue: Int(metronome.accentNote ?? 0)) ?? .none) (\(metronome.accentNote ?? 0))")
                        .monospacedDigit()
                    Text("Gap Measures: \(metronome.gapMeasureCount)")
                        .monospacedDigit()
                    Button(action: {
                        metronome.isPlaying.toggle()
                    }) {
                        Image(systemName: metronome.isPlaying ? "stop" : "play")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(metronome.isPlaying ? .red : .green)
                    }
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
