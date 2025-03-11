//  Copyright © 2025 Compiler, Inc. All rights reserved.

import Foundation
import CompilerSwiftAI

/// Metronome Parameters for decoding functions
public struct MetronomeParameters: Decodable, Sendable {
    public let bpm: Double?
    public let duration: Double?
    public let sound: String?
    public let count: Int?
}

/// Compiler Function
enum CompilerFunction: Decodable, Sendable, FunctionCallProtocol {
    
    typealias Parameters = MetronomeParameters
    
    /// Make the metronome start making sounds
    case play(response: String)
    
    /// Make the metronome no longer play sounds
    case stop(response: String)
    
    /// Set the tempo or speed of the metronome iin "beats per minute (bpm)"
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    case setTempo(bpm: Double, response: String)
    
    /// Increase or decrease the tempo of the metronome over a specified duration,
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    ///   - duration: The length of time in seconds it will take to reach the target tempo
    case rampTempo(bpm: Double, duration: Double, response: String)
    
    /// Change the primary sound of the metronome, which can be referred to as the pulse
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case changeSound(sound: String, response: String)
    
    /// Change the downbeat sound of the metronome, which can be referred to as the first beat sound
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case setDownBeat(sound: String, response: String)
    
    /// Change the upbeat sound of the metronome, which can be referred to as the accent
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case setUpBeat(sound: String, response: String)
    
    /// After every measure of the metronome playing, we can play any number of silent measures
    /// - Parameters:
    ///   - count: The number of measures of silence to be played
    case setGapMeasures(count: Int, response: String)
    
    /// This is returned if the function cound not be converted into appropriate functions
    case noOp(response: String)
    
    private enum CodingKeys: String, CodingKey {
        case function
        case parameters
        case colloquialDescription = "colloquial_response"
    }
    
    // MARK: - FunctionCallProtocol Properties
    
    var id: String {
        switch self {
        case .play: return "play"
        case .stop: return "stop"
        case .setTempo: return "setTempo"
        case .rampTempo: return "rampTempo"
        case .changeSound: return "changeSound"
        case .setDownBeat: return "setDownBeat"
        case .setUpBeat: return "setUpBeat"
        case .setGapMeasures: return "setGapMeasures"
        case .noOp: return "noOp"
        }
    }
    
    var parameters: MetronomeParameters {
        switch self {
        case .play, .stop, .noOp:
            return MetronomeParameters(bpm: nil, duration: nil, sound: nil, count: nil)
        case .setTempo(let bpm, _):
            return MetronomeParameters(bpm: bpm, duration: nil, sound: nil, count: nil)
        case .rampTempo(let bpm, let duration, _):
            return MetronomeParameters(bpm: bpm, duration: duration, sound: nil, count: nil)
        case .changeSound(let sound, _), .setDownBeat(let sound, _), .setUpBeat(let sound, _):
            return MetronomeParameters(bpm: nil, duration: nil, sound: sound, count: nil)
        case .setGapMeasures(let count, _):
            return MetronomeParameters(bpm: nil, duration: nil, sound: nil, count: count)
        }
    }
    
    var colloquialDescription: String {
        switch self {
        case .play(let desc),
             .stop(let desc),
             .setTempo(_, let desc),
             .rampTempo(_, _, let desc),
             .changeSound(_, let desc),
             .setDownBeat(_, let desc),
             .setUpBeat(_, let desc),
             .setGapMeasures(_, let desc),
             .noOp(let desc):
            return desc
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let functionName = try container.decode(String.self, forKey: .function)
        let parameters = try? container.decodeIfPresent(MetronomeParameters.self, forKey: .parameters)
        let colloquialDesc = try container.decodeIfPresent(String.self, forKey: .colloquialDescription) ?? "Processing metronome command"
        
        switch functionName {
        case "play":
            self = .play(response: colloquialDesc)
        case "stop":
            self = .stop(response: colloquialDesc)
        case "setTempo":
            guard let bpm = parameters?.bpm else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing bpm parameter")
            }
            self = .setTempo(bpm: bpm, response: colloquialDesc)
        case "rampTempo":
            guard let bpm = parameters?.bpm else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing bpm parameter")
            }
            guard let duration = parameters?.duration else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing duration parameter")
            }
            self = .rampTempo(bpm: bpm, duration: duration, response: colloquialDesc)
        case "changeSound":
            guard let sound = parameters?.sound else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing sound parameter")
            }
            self = .changeSound(sound: sound, response: colloquialDesc)
        case "setDownBeat":
            guard let sound = parameters?.sound else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing sound parameter")
            }
            self = .setDownBeat(sound: sound, response: colloquialDesc)
        case "setUpBeat":
            guard let sound = parameters?.sound else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing sound parameter")
            }
            self = .setUpBeat(sound: sound, response: colloquialDesc)
        case "setGapMeasures":
            guard let count = parameters?.count else {
                throw DecodingError.dataCorruptedError(forKey: .parameters, in: container, debugDescription: "Missing count parameter")
            }
            self = .setGapMeasures(count: count, response: colloquialDesc)
        default:
            self = .noOp(response: colloquialDesc)
        }
    }
}

struct MetronomeState: AppStateProtocol {
    let bpm: Double
}
