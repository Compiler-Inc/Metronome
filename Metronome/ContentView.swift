//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import CompilerSwiftAI

struct ContentView: View {
    @State var metronome = Metronome()
    @State var service = Service(apiKey: "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1",
                                appId: "1561de0c-8e1c-4ace-a870-ac0baecf40f6")

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
            ChatView(state: MetronomeState(bpm: metronome.tempo),
                     service: service,
                     describe: CompilerFunction.describe(function:),
                     execute:  metronome.execute(function:))
        }
        #endif
    }

}

#Preview {
    ContentView()
}
