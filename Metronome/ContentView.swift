//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import CompilerSwiftAI

struct ContentView: View {
    @State var metronome = Metronome()

    var body: some View {
        #if os(macOS)
        HStack(spacing: 0) {
            ChatView(state: MetronomeState(bpm: metronome.tempo),
                     service: service,
                     describe: CompilerFunction.describe(function:),
                     execute: metronome.execute(function:))
            MetronomeView(metronome: metronome)
        }
        .buttonStyle(.borderless)
        #else
        VStack(spacing: 0) {
            MetronomeView(metronome: metronome)
//            ChatView(state: MetronomeState(bpm: metronome.tempo),
//                     service: service,
//                     describe: CompilerFunction.describe(function:),
//                     execute:  metronome.execute(function:))
        }
        #endif
    }

}

#Preview {
    ContentView()
}
