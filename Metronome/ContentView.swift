//
//  ContentView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 12/10/24.
//

import SwiftUI

struct ContentView: View {
    @State var metronome = Metronome()

    var body: some View {
        VStack {
            Button {
                metronome.startRealtimeTranscription()
            } label: {
                Text("Start TX")
            }

            HStack(spacing: 20) {
                DLMView(metronome: $metronome)
                VStack {
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
                            Text(metronome.isPlaying ? "Stop" : "Play")
                                .font(.system(size: 60))
                                .foregroundColor(metronome.isPlaying ? .red : .green)
                        }
                    }
                }
            }
            .padding()
            

        }
        .padding()
    }

}

#Preview {
    ContentView()
}
