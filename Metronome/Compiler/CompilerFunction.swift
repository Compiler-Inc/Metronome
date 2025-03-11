//  Copyright 2025 Compiler, Inc. All rights reserved.

// Adding a comment to resolve git conflict
import Foundation
import CompilerSwiftAI

/// Compiler Function
enum CompilerFunction: Decodable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case function
        case parameters
        case colloquialDescription = "colloquial_response"
    }
    
    private enum FunctionType: String, Decodable {
        case play
        case stop
        case setTempo = "setTempo"
        case rampTempo = "rampTempo"
        case changeSound = "changeSound"
        case setDownBeat = "setDownBeat"
        case setUpBeat = "setUpBeat"
        case setGapMeasures = "setGapMeasures"
        case setNumberOfBeats = "setNumberOfBeats"
        case noOp = "noOp"
    }
    
    /// Make the metronome start making sounds
    struct PlayParameters: Decodable, Sendable {}
    case play(Function<PlayParameters>)
    
    /// Make the metronome no longer play sounds
    struct StopParameters: Decodable, Sendable {}
    case stop(Function<StopParameters>)
    
    /// Set the tempo or speed of the metronome in "beats per minute (bpm)"
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    struct SetTempoParameters: Decodable, Sendable {
        let bpm: Double
    }
    case setTempo(Function<SetTempoParameters>)
    
    /// Increase or decrease the tempo of the metronome over a specified duration
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    ///   - duration: The length of time in seconds it will take to reach the target tempo
    struct RampTempoParameters: Decodable, Sendable {
        let bpm: Double
        let duration: Double
    }
    case rampTempo(Function<RampTempoParameters>)
    
    /// Change the primary sound of the metronome, which can be referred to as the pulse
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    struct ChangeSoundParameters: Decodable, Sendable {
        let sound: String
    }
    case changeSound(Function<ChangeSoundParameters>)
    
    /// Change the downbeat sound of the metronome, which can be referred to as the first beat sound
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    struct SetDownBeatParameters: Decodable, Sendable {
        let sound: String
    }
    case setDownBeat(Function<SetDownBeatParameters>)
    
    /// Change the upbeat sound of the metronome, which can be referred to as the accent
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    struct SetUpBeatParameters: Decodable, Sendable {
        let sound: String
    }
    case setUpBeat(Function<SetUpBeatParameters>)
    
    /// After every measure of the metronome playing, we can play any number of silent measures
    /// - Parameters:
    ///   - count: The number of measures of silence to be played
    struct SetGapMeasureParameters: Decodable, Sendable {
        let count: Int
    }
    case setGapMeasures(Function<SetGapMeasureParameters>)
    
    /// Sets the number of beats that are shown on the metronome. This is also the top number of a traiditional Time Signature, so the user may say something like "Set the time signature to 7 4" and you will only change the first or top number.
    /// - Parameters:
    ///   - numberOfBeats: The number of beats to show, also the top number of a traditional time signature
    struct SetNumberOfBeatsParameters: Decodable, Sendable {
        let numberOfBeats: Int
    }
    case setNumberOfBeats(Function<SetNumberOfBeatsParameters>)
    
    /// This is returned if the function could not be converted into appropriate functions
    struct NoOpParameters: Decodable, Sendable {}
    case noOp(Function<NoOpParameters>)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let functionType = try container.decode(FunctionType.self, forKey: .function)
        let colloquialDesc = try container.decodeIfPresent(String.self, forKey: .colloquialDescription) ?? "Processing metronome command"
        
        switch functionType {
        case .play:
            self = .play(.init(id: functionType.rawValue, parameters: PlayParameters(), colloquialDescription: colloquialDesc))
        case .stop:
            self = .stop(.init(id: functionType.rawValue, parameters: StopParameters(), colloquialDescription: colloquialDesc))
        case .setTempo:
            let params = try container.decodeIfPresent(SetTempoParameters.self, forKey: .parameters) ?? nil
            self = .setTempo(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .rampTempo:
            let params = try container.decodeIfPresent(RampTempoParameters.self, forKey: .parameters) ?? nil
            self = .rampTempo(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .changeSound:
            let params = try container.decodeIfPresent(ChangeSoundParameters.self, forKey: .parameters) ?? nil
            self = .changeSound(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .setDownBeat:
            let params = try container.decodeIfPresent(SetDownBeatParameters.self, forKey: .parameters) ?? nil
            self = .setDownBeat(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .setUpBeat:
            let params = try container.decodeIfPresent(SetUpBeatParameters.self, forKey: .parameters) ?? nil
            self = .setUpBeat(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .setGapMeasures:
            let params = try container.decodeIfPresent(SetGapMeasureParameters.self, forKey: .parameters) ?? nil
            self = .setGapMeasures(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .setNumberOfBeats:
            let params = try container.decodeIfPresent(SetNumberOfBeatsParameters.self, forKey: .parameters) ?? nil
            self = .setNumberOfBeats(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        case .noOp:
            let params = try container.decodeIfPresent(NoOpParameters.self, forKey: .parameters) ?? nil
            self = .noOp(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
        }
    }
    
    var colloquialDescription: String {
        switch self {
        case .play(let function):
            return function.colloquialDescription
        case .stop(let function):
            return function.colloquialDescription
        case .setTempo(let function):
            return function.colloquialDescription
        case .rampTempo(let function):
            return function.colloquialDescription
        case .changeSound(let function):
            return function.colloquialDescription
        case .setDownBeat(let function):
            return function.colloquialDescription
        case .setUpBeat(let function):
            return function.colloquialDescription
        case .setGapMeasures(let function):
            return function.colloquialDescription
        case .noOp(let function):
            return function.colloquialDescription
        case .setNumberOfBeats(let function):
            return function.colloquialDescription
        }
    }
}

struct MetronomeState: AppStateProtocol {
    let bpm: Double
}
