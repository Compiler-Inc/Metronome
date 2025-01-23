//  Copyright © 2025 Compiler, Inc. All rights reserved.

import AudioKit
import CompilerSwiftAI

extension Metronome {

    func execute(command: Command<CommandArgs>) {
        print("🎯 DLM executing command: \(command)")
        
        guard let function = CompilerFunction.from(command) else {
            print("❌ Failed to parse command: \(command)")
            return
        }
        print("✅ Parsed command: \(function)")
        
        switch function {
        case .play:
            isPlaying = true
            
        case .stop:
            isPlaying = false
            
        case .setTempo(let bpm):
            tempo = bpm
            
        case .rampTempo(let bpm, let duration):
            rampTempo(bpm: bpm, duration: duration)
            
        case .changeSound(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                self.note = MIDINoteNumber(note)
            }
            
        case .setDownBeat(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                startingNote = MIDINoteNumber(note)
            }
            
        case .setUpBeat(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                accentNote = MIDINoteNumber(note)
            }
            
        case .setGapMeasures(let count):
            gapMeasureCount = count
            
        case .noOp:
            print("⚪️ NoOp command received")
        }
        print("✨ Finished executing all commands")
    }
}

struct CommandArgs: Codable, Sendable {
    let bpm: Double?
    let duration: Double?
    let sound: String?
    let count: Int?
}

struct CurrentState: Codable, Sendable {
    let bpm: Double
}
