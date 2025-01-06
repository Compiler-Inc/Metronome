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
        #if os(macOS)
        HStack(spacing: 0) {
            DLMView(metronome: metronome)
            MetronomeView(metronome: metronome)
        }
        .buttonStyle(.borderless)
        #else
        VStack {
            MetronomeView(metronome: metronome)
            DLMView(metronome: metronome)
        }
        #endif
    }

}

#Preview {
    ContentView()
}
