//  Copyright 2025 Compiler, Inc. All rights reserved.

import SwiftUI
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

struct MetronomeView: View {
    // Customizable light color
    @State private var lightColor = Color.red
    @State private var viewModel: MetronomeViewModel
        
    init(compiler: CompilerManager) {
        _viewModel = State(initialValue: MetronomeViewModel(compiler: compiler))
    }

    var body: some View {
        VStack(spacing: 40) {
            // Beat indicators/lights
            BeatsView(
                lightColor: lightColor,
                timeSignatureTop: viewModel.metronome.timeSignatureTop,
                currentBeat: viewModel.metronome.currentBeat
            )
            
            // Tempo slider and label
            VStack(spacing: 10) {
                Text("Tempo: \(Int(viewModel.metronome.tempo)) BPM")
                    .font(.title2)
                
                Slider(value: $viewModel.metronome.tempo, in: 40...208, step: 1)
                    .padding(.horizontal)
                    .tint(lightColor)
            }
            
            // Play/Stop button
            Button(action: {
                viewModel.metronome.togglePlayback()
            }) {
                Image(systemName: viewModel.metronome.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(lightColor)
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
            .padding()
            
            Spacer()
                       
            // Replace the SpeechButton with the InputSwitcherView
            InputSwitcherView(viewModel: viewModel)
        }
        .padding()
        .onAppear {
            viewModel.metronome.start()
            Task {
                try await viewModel.transcriber.requestAuthorization()
            }
        }
        .onDisappear {
            viewModel.metronome.stop()
        }
    }
}

#Preview("Metronome View") {
    MetronomeView(compiler: CompilerManager())
}
