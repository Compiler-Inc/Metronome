//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import CompilerSwiftAI

struct ContentView: View {
    @State var metronome = Metronome()
    @State var service = Service(apiKey: "a2481503d596614819c95f06eb33e9bed7145aec198d1cd319bcfad0765b53a3",
                                appId: "eefb224c-f823-4190-881e-e54484d2cd9d")

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
