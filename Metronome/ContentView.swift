//
//  ContentView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 12/10/24.
//

import SwiftUI

struct ContentView: View {
    @State var metronome = Metronome()
    @State var dlm = DLMService()

    @State private var audioFileTranscript: String = ""
    @State private var promptTranscript: String = ""
    @State private var dlmResponse: String = ""
    @State private var isProcessingDLM = false
    @State private var realtimeTranscript: String = ""
    @State private var realtimeTranscriptBuffer: String = ""
    @State private var isProcessingAudioCommands = false
    @State private var processingSteps: [String] = []

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                DLMView(
                    metronome: $metronome,
                    dlm: $dlm,
                    realtimeTranscript: $realtimeTranscript,
                    isProcessingAudioCommands: $isProcessingAudioCommands                )
                Button(action: {
                    print("dec tempo")
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
            .padding()
            
            Button(action: {
                metronome.isPlaying.toggle()
            }) {
                Image(systemName: metronome.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(metronome.isPlaying ? .red : .green)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
