//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct MetronomeView: View {
    @State var conductor = MetronomeConductor()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(conductor.data.isPlaying ? "Stop" : "Start").onTapGesture {
                    conductor.data.isPlaying.toggle()
                }
                VStack {
                    Text("Tempo: \(Int(conductor.data.tempo))")
                    Slider(value: $conductor.data.tempo, in: 60.0 ... 240.0, label: {
                        Text("Tempo")
                    })
                }
            }
            Spacer()

            HStack(spacing: 10) {
                ForEach(0 ..< conductor.data.timeSignatureTop, id: \.self) { index in
                    ZStack {
                        Circle().foregroundColor(conductor.data.currentBeat == index ? .red : .white)
                        Text("\(index + 1)").foregroundColor(.black)
                    }.onTapGesture {
                        conductor.data.timeSignatureTop = index + 1
                    }
                }
                ZStack {
                    Circle().foregroundColor(.white)
                    Text("+").foregroundColor(.black)
                }
                .onTapGesture {
                    conductor.data.timeSignatureTop += 1
                }
            }.padding()
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
