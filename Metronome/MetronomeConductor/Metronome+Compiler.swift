//  Copyright 2025 Compiler, Inc. All rights reserved.

import AudioKit
import CompilerSwiftAI

extension MetronomeConductor {
    func execute(function: CompilerFunction) {
        switch function {
        case .play:
            data.isPlaying = true
            
        case .stop:
            data.isPlaying = false
            
        case .setTempo(let function):
            guard let params = function.parameters else { return }
            data.tempo = params.bpm
            
        case .rampTempo(let function):
            guard let params = function.parameters else { return }
            rampTempo(bpm: params.bpm, duration: params.duration)
            
        case .changeSound(let function):
            guard let params = function.parameters,
                  let sound = GiantSound.allCases.first(where: { $0.description == params.sound })
            else { return }
            self.data.note = MIDINoteNumber(sound.rawValue)
            
        case .setDownBeat(let function):
            guard let params = function.parameters,
                  let sound = GiantSound.allCases.first(where: { $0.description == params.sound })
            else { return }
            
            data.startingNote = MIDINoteNumber(sound.rawValue)
            
        case .setUpBeat(let function):
            guard let params = function.parameters,
                  let sound = GiantSound.allCases.first(where: { $0.description == params.sound })
            else { return }
            data.accentNote = MIDINoteNumber(sound.rawValue)
            
        case .setGapMeasures(let function):
            guard let params = function.parameters else { return }
            data.gapMeasureCount = params.count
            
        case .noOp:
            print("NoOp received")
        }
        print("Finished executing all functions")
    }
}
