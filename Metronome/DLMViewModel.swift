//
//  DLMViewModel.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import Foundation
import AudioKit

@MainActor
@Observable
class DLMViewModel {
    
    let deepgram = DeepgramService(apiKey: "95536b5a0b268e8d3392854a7d4858386278af2c")
    private let audioEngine = AudioEngine()
    private var promptTap: RawDataTap?
    private let silencer = Mixer()
    
    var processingSteps: [ProcessingStep] = []
    
    var manualCommand = ""
    
    init() {
        deepgram.onTranscriptReceived = { transcript in
            Task { @MainActor in
                if !self.manualCommand.isEmpty {
                    self.manualCommand += " "
                }
                self.manualCommand += transcript
            }
        }
        
        deepgram.onTranscriptionComplete = {
            Task { @MainActor in
                print("transcription complete")
            }
        }
    }
    
    public func addStep(_ text: String) {
        processingSteps.append(ProcessingStep(text: text, isComplete: false))
    }

    public func completeLastStep() {
        if let lastIndex = processingSteps.indices.last {
            processingSteps[lastIndex].isComplete = true
        }
    }
    
    func startRealtimeTranscription() {
        
        guard let input = audioEngine.input else {
            print("No input!")
            return
        }
        
        silencer.addInput(input)
        silencer.volume = 0
        audioEngine.output = silencer
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            return
        }
        
        promptTap = RawDataTap(input, bufferSize: 4096) { buffer in
            self.deepgram.sendAudioData(buffer)
        }
        promptTap?.start()
        
        // Start WebSocket connection
        deepgram.startRealtimeTranscription()
    }
    
    func stopRealtimeTranscription() {
        promptTap?.stop()
        promptTap = nil
        deepgram.stopRealtimeTranscription()
        audioEngine.stop()
    }
    
}
