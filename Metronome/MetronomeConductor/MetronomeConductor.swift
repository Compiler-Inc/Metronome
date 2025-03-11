//  Copyright © 2025 Compiler, Inc. All rights reserved.

import Foundation
import AudioKit
import AudioKitEX
import AudioKitUI
import STKAudioKit
import SwiftUI
import CompilerSwiftAI

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
    var isPlaying = false
    var timeSignatureTop: Int = 4
    var beatNoteVelocity = 100.0
    var currentBeat = 0
    var color: Color = .red
}

@Observable
class MetronomeConductor: HasAudioEngine {
    let engine = AudioEngine()
    let sampler = AppleSampler()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    var sequencer = Sequencer()
    var timer = Timer()
    
    private let beatUpdateQueue = DispatchQueue(label: "com.metronome.beatUpdate")

    var data = MetronomeData() {
        didSet {
            data.isPlaying ? sequencer.play() : sequencer.stop()
            sequencer.tempo = data.tempo
            updateSequences()
        }
    }
    
    init() {
        let soundFont = "Giant"
        do {
            try sampler.loadPercussiveSoundFont(soundFont)
        } catch let err {
            print("error: \(err)")
        }

        _ = sequencer.addTrack(for: sampler)

        callbackInst = CallbackInstrument(midiCallback: { [weak self] _, beat, _ in
            self?.updateCurrentBeat(Int(beat))
            print(beat)
        })

        _ = sequencer.addTrack(for: callbackInst)
        updateSequences()

        mixer.addInput(sampler)
        mixer.addInput(callbackInst)

        engine.output = mixer
    }

    private func updateCurrentBeat(_ beat: Int) {
        beatUpdateQueue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.data.currentBeat = beat
            }
        }
    }
}

//MARK: - Sequencer Functions
extension MetronomeConductor {
    func updateSequences() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        var track = sequencer.tracks.first!

        track.length = Double(data.timeSignatureTop)

        track.clear()
        track.sequence.add(noteNumber: data.note, position: 0.0, duration: 0.4)
        let vel = MIDIVelocity(Int(data.beatNoteVelocity))
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: data.note, velocity: vel, position: Double(beat), duration: 0.1)
        }
        
        if let s = data.startingNote {
            track.sequence.add(noteNumber: s, position: 0, duration: 0.1)
        }
        
        if let a = data.accentNote {
            // Determine weak beats based on time signature and add accent notes
            for beat in 0 ..< data.timeSignatureTop {
                if isWeakBeat(beat, timeSignatureTop: data.timeSignatureTop) {
                    track.sequence.add(noteNumber: a, position: Double(beat), duration: 0.1)
                }
            }
        }
        
        track = sequencer.tracks[1]
        track.length = Double(data.timeSignatureTop)
        track.clear()
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }
        
        sequencer.length = Double(data.gapMeasureCount + 1) * Double(data.timeSignatureTop)
        
    }

    private func isWeakBeat(_ beat: Int, timeSignatureTop: Int) -> Bool {
        // In most time signatures, the first beat (index 0) is strong
        if beat == 0 {
            return false
        }
        
        switch timeSignatureTop {
        case 2:
            // In 2/4 time, beat 2 (index 1) is weak
            return true
        case 3:
            // In 3/4 time, beats 2 and 3 (indexes 1 and 2) are weak
            return true
        case 4:
            // In 4/4 time, beats 2 and 4 (indexes 1 and 3) are weak
            return beat == 1 || beat == 3
        case 6:
            // In 6/8 time, beats 1 and 4 (indexes 0 and 3) are strong, others weak
            return beat != 0 && beat != 3
        case 9:
            // In 9/8 time, beats 1, 4, and 7 (indexes 0, 3, and 6) are strong
            return beat % 3 != 0
        case 12:
            // In 12/8 time, beats 1, 4, 7, and 10 (indexes 0, 3, 6, and 9) are strong
            return beat % 3 != 0
        default:
            // For other time signatures, use a general rule: odd-indexed beats are weak
            return beat % 2 != 0
        }
    }
}

//MARK: - Tempo Functions
extension MetronomeConductor {
    func rampTempo(bpm: Double, duration: TimeInterval) {
        data.startTempo = data.tempo
        data.targetTempo = bpm
        data.targetDuration = duration
        data.startTime = Date()
    }
    
    @objc func fireTimer() {
        if let start = data.startTime, let target = data.targetTempo, let duration = data.targetDuration {
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
}
