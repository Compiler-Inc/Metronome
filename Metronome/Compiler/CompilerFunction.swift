//  Copyright 2025 Compiler, Inc. All rights reserved.

import Foundation
import CompilerSwiftAI

enum CompilerFunction: Decodable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case function
        case parameters
        case colloquialDescription = "colloquial_response"
    }
    
    private enum FunctionType: String, Decodable {
        case play
        case stop
        case setTempo
        case rampTempo
        case changeSound
        case setDownBeat
        case setUpBeat
        case setGapMeasures
        case setNumberOfBeats
        case setColor
        case noOp
    }
    
    struct PlayParameters: Decodable, Sendable {}
    case play(Function<PlayParameters>)
    
    struct StopParameters: Decodable, Sendable {}
    case stop(Function<StopParameters>)

    struct SetTempoParameters: Decodable, Sendable {
        let bpm: Double
    }
    case setTempo(Function<SetTempoParameters>)

    struct RampTempoParameters: Decodable, Sendable {
        let bpm: Double
        let duration: Double
    }
    case rampTempo(Function<RampTempoParameters>)
    
    struct ChangeSoundParameters: Decodable, Sendable {
        let sound: String
    }
    case changeSound(Function<ChangeSoundParameters>)
    
    struct SetDownBeatParameters: Decodable, Sendable {
        let sound: String
    }
    case setDownBeat(Function<SetDownBeatParameters>)
    
    struct SetUpBeatParameters: Decodable, Sendable {
        let sound: String
    }
    case setUpBeat(Function<SetUpBeatParameters>)
    
    struct SetGapMeasureParameters: Decodable, Sendable {
        let count: Int
    }
    case setGapMeasures(Function<SetGapMeasureParameters>)
    
    struct SetNumberOfBeatsParameters: Decodable, Sendable {
        let numberOfBeats: Int
    }
    case setNumberOfBeats(Function<SetNumberOfBeatsParameters>)
    
    struct SetColorParameters: Decodable, Sendable {
        let color: String
    }
    case setColor(Function<SetColorParameters>)
    
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
            case .setColor:
                let params = try container.decodeIfPresent(SetColorParameters.self, forKey: .parameters) ?? nil
                self = .setColor(.init(id: functionType.rawValue, parameters: params, colloquialDescription: colloquialDesc))
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
            case .setColor(let function):
                return function.colloquialDescription
        }
    }
}
