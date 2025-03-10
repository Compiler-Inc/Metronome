import AudioKit
import CompilerSwiftAI

extension MetronomeConductor {
    func execute(function: Function<MetronomeParameters>) {
        print("🎯 Executing fucntion: \(function)")
        
        guard let metronomeFunction = CompilerFunction.from(function) else {
            print("❌ Failed to parse function: \(function)")
            return
        }
        print("✅ Parsed function: \(metronomeFunction)")
        
        switch metronomeFunction {
        case .play:
            data.isPlaying = true
            
        case .stop:
            data.isPlaying = false
            
        case .setTempo(let bpm):
            data.tempo = bpm
            
        case .rampTempo(let bpm, let duration):
            rampTempo(bpm: bpm, duration: duration)
            
        case .changeSound(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                self.data.note = MIDINoteNumber(note)
            }
            
        case .setDownBeat(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                data.startingNote = MIDINoteNumber(note)
            }
            
        case .setUpBeat(let sound):
            let s = GiantSound.allCases.first(where: {$0.description == sound})
            if let note = s?.rawValue {
                data.accentNote = MIDINoteNumber(note)
            }
            
        case .setGapMeasures(let count):
            data.gapMeasureCount = count
            
        case .noOp:
            print("⚪️ NoOp received")
        }
        print("✨ Finished executing all functions")
    }
}

struct MetronomeParameters: Codable, Sendable {
    let bpm: Double?
    let duration: Double?
    let sound: String?
    let count: Int?
}

struct MetronomeState: Codable, Sendable {
    let bpm: Double
}
