//  Copyright 2025 Compiler, Inc. All rights reserved.

import CompilerHelper
import CompilerSwiftAI

@CompilerFunctionGenerator
enum CompilerFunctionDef {
    /// Make the metronome start making sounds
    case play
    
    /// Make the metronome no longer play sounds
    case stop
    
    /// Set the tempo or speed of the metronome iin "beats per minute (bpm)"
    /// - Parameters:
    ///   - bpm: The target tempo in beats per minute, need to be between 20 and 300
    case setTempo(bpm: Double)
    
    /// Set the numerator in the time signature
    /// - Parameters:
    ///   - numberOfBeats: The number of beats in one measure
    case setNumberOfBeats(numberOfBeats: Int)
    
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
    
    /// Set the primary color used in the user interface
    /// - Parameters:
    ///   - color: The tint of the UI
    case setColor(color: String)
    case noOp
}

