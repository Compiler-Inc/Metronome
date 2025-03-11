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
    
    private let sysetemPrompt: String = """
You will be given a query asking for the BPM (beats per minute) or tempo of a specific song. Your task is to provide only the song title and its BPM, without any additional explanation or text.

Here is the query:
<song_query>
{{SONG_QUERY}}
</song_query>

Instructions:
1. Extract the song title and artist (if provided) from the query.
2. Look up the BPM for the specified song.
3. Respond with only the song title followed by a colon, then the BPM number, and "BPM".
4. Do not include any other information, explanations, or text in your response.

Format your response as follows:
<answer>
[Song Title]: [BPM number] BPM
</answer>

Remember: Provide only the song title and BPM. Do not include any additional information or explanations.
"""
    
    @MainActor
    func processFunctionPrompt(_ text: String) async {
        // Skip processing if text is empty
        guard !text.isEmpty else { return }
        do {
            isProcessingPrompt = true
            defer { isProcessingPrompt = false }
            let functions = try await compiler.getFunctions(for: text)
            
            // Clear previous function descriptions
            functionDescriptions.removeAll()
            
            // Collect descriptions from all functions
            for function in functions {
                conductor.execute(function: function)
                
                // Add the function's colloquial description
                functionDescriptions.append(function.colloquialDescription)
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
    
    @MainActor
    func processModelPrompt(_ text: String) async {
        guard !text.isEmpty else { return }
        
        do {
            isProcessingPrompt = true
            defer { isProcessingPrompt = false }
            let messages: [Message] = [Message(id: "0", role: .system, content: sysetemPrompt), Message(id: "1", role: .user, content: text)]
            
            let completion = try await compiler.client.generateText(request: .init(messages: messages, model: "chatgpt-4o-latest"), using: .openAI(.gpt4o))
            functionDescriptions.removeAll()
            
            let generatedText = completion.choices.first?.message.content ?? ""
            
            print("generated text:\(generatedText)")
            functionDescriptions.append(generatedText)
            
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
            print("Erro processing model prompt: \(error.localizedDescription)")
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
            await processFunctionPrompt(transcribedText)
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
