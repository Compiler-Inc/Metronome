//  Copyright © 2025 Compiler, Inc. All rights reserved.

import Foundation
import SwiftUI
import Transcriber
import CompilerSwiftAI

@Observable
@MainActor
final class MetronomeViewModel {
    private var compiler: CompilerManager
    private var conductor: MetronomeConductor
    public var transcriber: TranscriberService
    
    var metronome: MetronomeState!
    var functionDescriptions: [String] = []
    var showFunctionNotification: Bool = false
    var functionNotificationTimer: Timer?
    
    init(compiler: CompilerManager) {
        self.compiler = compiler
        self.conductor = MetronomeConductor()
        self.transcriber = TranscriberService()
        self.metronome = MetronomeState(conductor: conductor)
    }
    
    public var isProcessingPrompt: Bool = false
    
    var isTextInputMode: Bool = false
    
    @MainActor
    func processPrompt(_ text: String) async {
        // Skip processing if text is empty
        guard !text.isEmpty else { return }
        do {
            isProcessingPrompt = true
            defer { isProcessingPrompt = false }
            let functions = try await compiler.getFunctions(for: text, and: metronome.compilerState)
            
            // Clear previous function descriptions
            functionDescriptions.removeAll()
            
            // Collect descriptions from all functions
            for function in functions {
                conductor.execute(function: function)
                
                // Add the function's colloquial description
                functionDescriptions.append(function.colloquialResponse)
            }
            
            // Show notification if we have any function descriptions
            if !functionDescriptions.isEmpty {
                showFunctionNotification = true
                
                // Cancel any existing timer
                functionNotificationTimer?.invalidate()
                
                // Set a timer to hide the notification after 5 seconds
                functionNotificationTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
                    Task { @MainActor in
                        self?.showFunctionNotification = false
                    }
                }
            }
        } catch {
            // Handle any errors
            print("Error processing transcription: \(error.localizedDescription)")
        }
    }
    
    // Record speech and process the transcription
    @MainActor
    func toggleTranscription() async {
        // If we're already recording, just stop recording
        if transcriber.isRecording {
            transcriber.toggleRecording()
            return
        }
        
        // Otherwise, start a new recording session and process the result
        
        let transcribedText = await transcriber.recordAndTranscribe()
        
        // Process the text
        if !transcribedText.isEmpty {
            await processPrompt(transcribedText)
        }
    }
}

extension MetronomeViewModel {
    @Observable
    class MetronomeState {
        private var conductor: MetronomeConductor
        
        init(conductor: MetronomeConductor) {
            self.conductor = conductor
        }
        
        var isPlaying: Bool {
            get { conductor.data.isPlaying }
            set { conductor.data.isPlaying = newValue }
        }
        
        var tempo: Double {
            get { conductor.data.tempo }
            set { conductor.data.tempo = newValue }
        }
        
        var timeSignatureTop: Int {
            get { conductor.data.timeSignatureTop }
            set { conductor.data.timeSignatureTop = newValue }
        }
        
        var currentBeat: Int {
            conductor.data.currentBeat
        }
        
        var color: Color {
            conductor.data.color
        }
        
        var compilerState: CompilerMetronomeState {
            get {
                CompilerMetronomeState(
                    bpm: tempo,
                    timeSignatureTop: timeSignatureTop,
                    isPlaying: isPlaying,
                    gapMeasureCount: conductor.data.gapMeasureCount,
                    targetDuration: conductor.data.targetDuration,
                    targetTempo: conductor.data.targetTempo
                )
            }
        }
        
        // Methods
        func togglePlayback() {
            conductor.data.isPlaying.toggle()
        }
        
        func rampTempo(to bpm: Double, duration: TimeInterval) {
            conductor.rampTempo(bpm: bpm, duration: duration)
        }
        
        func start() {
            conductor.start()
        }
        
        func stop() {
            conductor.stop()
        }
    }
}

struct CompilerMetronomeState: Encodable & Sendable {
    let bpm: Double
    let timeSignatureTop: Int
    let isPlaying: Bool
    let gapMeasureCount: Int
    let targetDuration: TimeInterval?
    let targetTempo: Double?
    
}
