//  Copyright 2025 Compiler, Inc. All rights reserved.

import AudioKit
import AudioKitEX
import SwiftUI

struct MetronomeData {
    var note: MIDINoteNumber = MIDINoteNumber(GiantSound.closedHiHat.rawValue)
    var startingNote: MIDINoteNumber?
    var accentNote: MIDINoteNumber?
    var tempo: Double = 120.0
    var startTempo: Double = 120.0
    var gapMeasureCount: Int = 0
    var startTime: Date?
    var targetDuration: TimeInterval?
    var targetTempo: Double?
    var isPlaying: Bool = false
    var timeSignatureTop: Int = 4
    var currentBeat = 0
}

@MainActor
@Observable
class Metronome {
    let engine = AudioEngine()
    let sampler = AppleSampler()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    let sequencer = Sequencer()
    var timer = Timer()
    
    // Add private queue for beat updates
    private let beatUpdateQueue = DispatchQueue(label: "com.metronome.beatUpdate")

    var data = MetronomeData() {
        didSet {
            if oldValue.note != data.note ||
               oldValue.startingNote != data.startingNote ||
               oldValue.accentNote != data.accentNote ||
               oldValue.gapMeasureCount != data.gapMeasureCount {
//                setupSequencer()
                sequencer.play()
            }
            if oldValue.tempo != data.tempo {
                sequencer.tempo = data.tempo
            }
            if oldValue.isPlaying != data.isPlaying {
                data.isPlaying ? sequencer.play() : sequencer.stop()
            }
        }
    }

    @objc func fireTimer() {
        if let start = data.startTime,
           let target = data.targetTempo,
           let duration = data.targetDuration {
            let elapsedTime = Date().timeIntervalSince(start)
            if elapsedTime < duration {
                data.tempo = data.startTempo + (elapsedTime/duration) * (target - data.startTempo)
            } else {
                data.tempo = target
                data.startTime = nil
                data.targetTempo = nil
                data.targetDuration = nil
            }
        }
    }

    func rampTempo(bpm: Double, duration: TimeInterval) {
        data.startTempo = data.tempo
        data.targetTempo = bpm
        data.targetDuration = duration
        data.startTime = Date()
    }

    init() {
        let soundFont = "Giant"
        do {
            try sampler.loadPercussiveSoundFont(soundFont)
        } catch let err {
            print("error: \(err)")
        }
        
        // Add track for sampler
        _ = sequencer.addTrack(for: sampler)

        callbackInst = CallbackInstrument(midiCallback: { [weak self] _, beat, _ in
            self?.beatUpdateQueue.async {
                guard let self = self else { return }
                Task { @MainActor in
                    self.data.currentBeat = Int(beat)
                    print(beat)
                }
            }
        })
        
        _ = sequencer.addTrack(for: callbackInst)
        updateSequences()
        
        // Add both instruments to mixer
        mixer.addInput(sampler)
        mixer.addInput(callbackInst)

        // Set mixer as engine output
        engine.output = mixer
        
//        setupSequencer()

        // Start the engine
        do {
            try engine.start()
        } catch {
            print("AudioKit engine failed to start: \(error.localizedDescription)")
        }
    }
    
    func updateSequences() {
        var track = sequencer.tracks.first!
        
        track.length = Double(data.timeSignatureTop)
        
        track.clear()
        track.sequence.add(noteNumber: data.note, position: 0.0, duration: 0.4)
        
        for beat in 1 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: data.note, position: Double(beat), duration: 0.1)
        }
        
        // Add callback track similar to STKView
        track = sequencer.tracks[1]
        track.length = Double(data.timeSignatureTop)
        track.clear()
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }

    }
    
//    private func setupSequencer() {
//        timer.invalidate()
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
//
//        sequencer.tracks.removeAll()
//        sequencer.addTrack(for: sampler)
//        sequencer.tempo = data.tempo
//
//        for beat in 0..<4 {
//            sequencer.tracks[0].add(noteNumber: data.note, position: Double(beat), duration: 0.1)
//        }
//
//        if let s = data.startingNote {
//            sequencer.tracks[0].add(noteNumber: s, position: 0, duration: 0.1)
//        }
//
//        if let a = data.accentNote {
//            sequencer.tracks[0].add(noteNumber: a, position: 1, duration: 0.1)
//            sequencer.tracks[0].add(noteNumber: a, position: 3, duration: 0.1)
//        }
//
//        sequencer.length = Double(data.gapMeasureCount + 1) * 4.0
//        sequencer.loopEnabled = true
//    }

}
