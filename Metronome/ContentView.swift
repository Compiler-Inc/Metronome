//
//  ContentView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 12/10/24.
//

import SwiftUI
import CompilerSwiftAI

struct ContentView: View {
    @State var metronome = Metronome()
    @State var dlm = DLMService(apiKey: "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1",
                                appId: "1561de0c-8e1c-4ace-a870-ac0baecf40f6")
    @State var deepgram = DeepgramService(apiKey: "95536b5a0b268e8d3392854a7d4858386278af2c")

    var body: some View {
        #if os(macOS)
        HStack(spacing: 0) {
            DLMView(state: CurrentState(bpm: metronome.tempo),
                    dlm: dlm,
                    deepgram: deepgram,
                    describe: describe(command:),
                    execute: metronome.execute(command:))
            MetronomeView(metronome: metronome)
        }
        .buttonStyle(.borderless)
        #else
        VStack(spacing: 0) {
            MetronomeView(metronome: metronome)
            DLMView(state: CurrentState(bpm: metronome.tempo), dlm: dlm, deepgram: deepgram, execute: metronome.executeCommands)
        }
        #endif
    }

}

#Preview {
    ContentView()
}
