import CompilerSwiftAI

enum MetronomeCommand: Sendable {
    case play
    case stop
    case setTempo(bpm: Double)
    case rampTempo(bpm: Double, duration: Double)
    case changeSound(sound: String)
    case setDownBeat(sound: String)
    case setUpBeat(sound: String)
    case setGapMeasures(count: Int)
    case noOp

    static func from(_ command: DLMCommand<CommandArgs>) -> MetronomeCommand? {
        switch command.command {
        case "play":
            return .play
        case "stop":
            return .stop
        case "setTempo":
            guard let bpm = command.args?.bpm else { return nil }
            return .setTempo(bpm: bpm)
        case "rampTempo":
            guard let bpm = command.args?.bpm else { return nil }
            guard let duration = command.args?.duration else { return nil }
            return .rampTempo(bpm: bpm, duration: duration)
        case "changeSound":
            guard let sound = command.args?.sound else { return nil }
            return .changeSound(sound: sound)
        case "setDownBeat":
            guard let sound = command.args?.sound else { return nil }
            return .setDownBeat(sound: sound)
        case "setUpBeat":
            guard let sound = command.args?.sound else { return nil }
            return .setUpBeat(sound: sound)
        case "setGapMeasures":
            guard let count = command.args?.count else { return nil }
            return .setGapMeasures(count: count)
        default:
            return nil
        }
    }
}

func describe(command: DLMCommand<CommandArgs>) -> String {
    
    guard let metronomeCommand = MetronomeCommand.from(command) else {
        print("❌ Failed to parse command: \(command)")
        return "Unknown command"
    }
    
    switch metronomeCommand {
        
    case .play:
        return "Starting metronome"
    case .stop:
        return "Stopping metronome"
    case .setTempo(bpm: let bpm):
        return "Setting tempo to \(bpm) BPM"
    case .rampTempo(bpm: let bpm, duration: let duration):
        return "Ramping tempo to \(bpm) BPM over \(duration) seconds"
    case .changeSound(sound: let sound):
        return "Setting sound to \(sound)"
    case .setDownBeat(sound: let sound):
        return "Setting downbeat to \(sound)"
    case .setUpBeat(sound: let sound):
        return "Setting upbeat to \(sound)"
    case .setGapMeasures(count: let count):
        return "Setting gap measures to \(count)"
    case .noOp:
        return "NoOp"
    }
}
