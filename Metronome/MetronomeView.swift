//  Copyright 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct MetronomeView: View {
    @State var conductor = MetronomeConductor()

    // Customizable light color
    @State private var lightColor = Color.red

    var body: some View {
        VStack(spacing: 40) {
            // Beat indicators/lights
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(0..<conductor.data.timeSignatureTop, id: \.self) { beatIndex in
                        Circle()
                            .fill(beatIndex == conductor.data.currentBeat ? lightColor : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .shadow(color: beatIndex == conductor.data.currentBeat ? lightColor.opacity(0.8) : .clear,
                                    radius: 10, x: 0, y: 0)
                            .animation(.easeOut(duration: 0.1), value: conductor.data.currentBeat)
                            .frame(width: geometry.size.width / CGFloat(conductor.data.timeSignatureTop))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
            .padding()
            
            // Tempo slider and label
            VStack(spacing: 10) {
                Text("Tempo: \(Int(conductor.data.tempo)) BPM")
                    .font(.title2)
                
                Slider(value: $conductor.data.tempo, in: 40...208, step: 1)
                    .padding(.horizontal)
                    .tint(lightColor)
            }
            
            // Play/Stop button
            Button(action: {
                conductor.data.isPlaying.toggle()
            }) {
                Image(systemName: conductor.data.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(lightColor)
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
