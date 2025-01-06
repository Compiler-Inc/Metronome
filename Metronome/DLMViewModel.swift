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
    
    let deepgram = DeepgramService()
    let audioEngine = AudioEngine()
    private var promptTap: RawDataTap?
    let silencer = Mixer()
    
    var processingSteps: [ProcessingStep] = []
    
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
