//  Copyright © 2025 Compiler, Inc. All rights reserved.

import Foundation
import Transcriber

@Observable
@MainActor
final class MetronomeViewModel {
    private var compiler: CompilerManager
    private var conductor: MetronomeConductor
    public var transcriber: TranscriberService
    
    var metronome: MetronomeState!
    
    init(compiler: CompilerManager) {
        self.compiler = compiler
        self.conductor = MetronomeConductor()
        self.transcriber = TranscriberService()
        self.metronome = MetronomeState(conductor: conductor)
    }
    
    public var isProcessingPrompt: Bool = false
    
    var isTextInputMode: Bool = false
    
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
    
    @MainActor
    func processPrompt(_ text: String) async {
        // Skip processing if text is empty
        guard !text.isEmpty else { return }

        do {
            isProcessingPrompt = true
            defer { isProcessingPrompt = false }
            let functions = try await compiler.getFunctions(for: text)
            
            for function in functions {
                conductor.execute(function: function)
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
