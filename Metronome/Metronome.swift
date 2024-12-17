import AudioKit
import CAudioKitEX
import AudioKitEX
import SwiftUI

@Observable
class Metronome {
    let engine = AudioEngine()
    let sampler = AppleSampler()

    var tempo = 120.0 {
        didSet {
            sequencer.tempo = tempo
        }
    }

    var isPlaying: Bool = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }

    let mixer = Mixer()
    let sequencer = Sequencer()

    func setTempo(bpm: Double, bars: Int) {

    }

    init() {
        // Connect samplers to mixer
        mixer.addInput(sampler)

        // Connect mixer to engine output
        engine.output = mixer
        
        setupSequencer()

        // Start the engine
        do {
            try engine.start()
        } catch {
            print("AudioKit engine failed to start: \(error.localizedDescription)")
        }
    }
    
    private func setupSequencer() {

        // Add tracks to sequencer
        sequencer.addTrack(for: sampler)

        // Set tempo
        sequencer.tempo = tempo

        // Add regular pulse on every beat
        for beat in 0..<4 {
            sequencer.tracks[0].add(noteNumber: 60, position: Double(beat), duration: 0.1)
        }

        // Set length to 4 beats (one bar)
        sequencer.length = 4.0
        sequencer.loopEnabled = true
    }

}
