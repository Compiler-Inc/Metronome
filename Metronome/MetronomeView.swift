//  Copyright 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct MetronomeView: View {
    @State var conductor = MetronomeConductor()

    var body: some View {
        VStack(spacing: 40) {
            // Beat indicators/lights
            HStack(spacing: 10) {
                ForEach(0..<conductor.data.timeSignatureTop, id: \.self) { beatIndex in
                    Circle()
                        .fill(beatIndex == conductor.data.currentBeat ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            // Tempo slider and label
            VStack(spacing: 10) {
                Text("Tempo: \(Int(conductor.data.tempo)) BPM")
                    .font(.title2)
                
                Slider(value: $conductor.data.tempo, in: 40...208, step: 1)
                    .padding(.horizontal)
            }
            
            // Play/Stop button
            Button(action: {
                conductor.data.isPlaying.toggle()
            }) {
                Image(systemName: conductor.data.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 24))
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
            .padding()
        }
        .padding()
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
