//  Copyright 2025 Compiler, Inc. All rights reserved.

import AudioKit
import CompilerSwiftAI

extension MetronomeConductor {
    func execute(function: CompilerFunction) {
        switch function {
        case .play(_):
            data.isPlaying = true
            
        case .stop(_):
            data.isPlaying = false
            
        case .setTempo(let bpm, _):
            data.tempo = bpm
            
        case .rampTempo(let bpm, let duration, _):
            rampTempo(bpm: bpm, duration: duration)
            
        case .changeSound(let sound, _):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                self.data.note = MIDINoteNumber(note)
            }
            
        case .setDownBeat(let sound, _):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                data.startingNote = MIDINoteNumber(note)
            }
            
        case .setUpBeat(let sound, _):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                data.accentNote = MIDINoteNumber(note)
            }
            
        case .setGapMeasures(let count, _):
            data.gapMeasureCount = count
            
        case .noOp(_):
            print(" NoOp received")
        }
        print(" Finished executing all functions")
    }
}
