//  Copyright © 2025 Compiler, Inc. All rights reserved.

import Foundation
import CompilerSwiftAI

/// Compiler Function
enum CompilerFunction: Sendable {
    
    /// Make the metronome start making sounds
    case play
    
    /// Make the metronome no longer play sounds
    case stop
    
    /// Set the tempo or speed of the metronome iin "beats per minute (bpm)"
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    case setTempo(bpm: Double)
    
    /// Increase or decrease the tempo of the metronome over a specified duration,
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    ///   - duration: The length of time in seconds it will take to reach the target tempo
    case rampTempo(bpm: Double, duration: Double)
    
    /// Change the primary sound of the metronome, which can be referred to as the pulse
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case changeSound(sound: String)
    
    /// Change the downbeat sound of the metronome, which can be referred to as the first beat sound
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case setDownBeat(sound: String)
    
    /// Change the upbeat sound of the metronome, which can be referred to as the accent
    /// - Parameters:
    ///   - sound: This sound has to be one of the following: snap, knock, Acoustic Bass Drum, Bass Drum 1, Side Stick, Acoustic Snare, Hand Clap, Electric Snare, Low Floor Tom, Closed Hi Hat, High Floor Tom, Pedal Hi-Hat, Low Tom, Open Hi-Hat, Low-Mid Tom, Hi Mid Tom, Crash Cymbal 1, High Tom, Ride Cymbal 1, Chinese Cymbal, Ride Bell, Tambourine, Splash Cymbal, Cowbell, Crash Cymbal 2, Vibraslap, Ride Cymbal 2, Hi Bongo, Low Bongo, Mute Hi Conga, Open Hi Conga, Low Conga, High Timbale, Low Timbale, High Agogo, Low Agogo, Cabasa, Maracas, Short Guiro, Long Guiro, Claves, Hi Wood Block, Low Wood Block, Mute Triangle, Open Triangle
    case setUpBeat(sound: String)
    
    /// After every measure of the metronome playing, we can play any number of silent measures
    /// - Parameters:
    ///   - count: The number of measures of silence to be played
    case setGapMeasures(count: Int)
    
    /// This is returned if the function cound not be converted into appropriate functions
    case noOp
    
    static func from(_ function: Function<MetronomeParameters>) -> CompilerFunction? {
        switch function.id {
        case "play":
            return .play
        case "stop":
            return .stop
        case "setTempo":
            guard let bpm = function.parameters?.bpm else { return nil }
            return .setTempo(bpm: bpm)
        case "rampTempo":
            guard let bpm = function.parameters?.bpm else { return nil }
            guard let duration = function.parameters?.duration else { return nil }
            return .rampTempo(bpm: bpm, duration: duration)
        case "changeSound":
            guard let sound = function.parameters?.sound else { return nil }
            return .changeSound(sound: sound)
        case "setDownBeat":
            guard let sound = function.parameters?.sound else { return nil }
            return .setDownBeat(sound: sound)
        case "setUpBeat":
            guard let sound = function.parameters?.sound else { return nil }
            return .setUpBeat(sound: sound)
        case "setGapMeasures":
            guard let count = function.parameters?.count else { return nil }
            return .setGapMeasures(count: count)
        default:
            return nil
        }
    }
}
