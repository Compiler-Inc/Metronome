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
        HStack(spacing: 0) {
            DLMView(metronome: metronome)
            MetronomeView(metronome: metronome)
        }
        .buttonStyle(.borderless)
    }

}

#Preview {
    ContentView()
}
