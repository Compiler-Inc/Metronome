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
    var functionDescriptions: [String] = []
    var showFunctionNotification: Bool = false
    var functionNotificationTimer: Timer?
    
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
                functionNotificationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
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

struct FunctionNotificationView: View {
    let descriptions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(descriptions, id: \.self) { description in
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    // No foreground color so it adapts automatically to the material
                    .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct TextInputView: View {
    @Binding var promptText: String
    var onSend: () -> Void
    var isProcessing: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            TextField("Send Prompt", text: $promptText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            
            Button(action: onSend) {
                if isProcessing {
                    // Show progress spinner when processing
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.0)
                } else {
                    // Show send icon when not processing
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                }
            }
            // Match the height of the text field and set button colors
            .frame(width: 40, height: 40)
            .background(isProcessing ? Color.green : Color.blue)
            .clipShape(Circle())
            .foregroundColor(.white)
            // Disable button when processing or text is empty
            .disabled(isProcessing || promptText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom, 25) // Maintain bottom padding
    }
}

struct InputSwitcherView: View {
    var viewModel: MetronomeViewModel
    @State private var promptText: String = ""
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) { // Change alignment to .top for the notification
            // Function notification appears at the top
            if viewModel.showFunctionNotification && !viewModel.functionDescriptions.isEmpty {
                FunctionNotificationView(descriptions: viewModel.functionDescriptions)
                    .animation(.spring(), value: viewModel.showFunctionNotification)
                    .zIndex(1) // Make sure it appears above other content
            }
            
            ZStack(alignment: .bottom) { // This ZStack contains the tab view and navigation hints
                // Use TabView with built-in swipe functionality
                TabView(selection: $selectedTab) {
                    // Speech button view
                    ZStack {
                        VStack(spacing: 10) {
                            // Show real-time transcription when recording
                            if viewModel.transcriber.isRecording {
                                Text(viewModel.transcriber.transcribedText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .animation(.easeInOut, value: viewModel.transcriber.transcribedText)
                            }
                            
                            SpeechButton(
                                isRecording: viewModel.transcriber.isRecording,
                                rmsValue: viewModel.transcriber.rmsValue,
                                isProcessing: viewModel.isProcessingPrompt,
                                supportsThinkingState: true,
                                onTap: {
                                    Task {
                                        await viewModel.toggleTranscription()
                                    }
                                }
                            )
                        }
                        // Center the speech button and add enough padding
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.bottom, 25)
                    }
                    .tag(0)
                    
                    // Text input view - pass isProcessingPrompt to handle thinking state
                    TextInputView(
                        promptText: $promptText,
                        onSend: {
                            Task {
                                await viewModel.processPrompt(promptText)
                                promptText = ""
                            }
                        },
                        isProcessing: viewModel.isProcessingPrompt
                    )
                    .padding(.bottom, 25)
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation hint label with improved positioning
                HStack {
                    if selectedTab == 1 {
                        // Show "← Swipe for Voice" when on text input
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9))
                            Text("Swipe for Voice")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                        .padding(.leading, 10)
                        .padding(.bottom, 5)
                    }
                    
                    Spacer()
                    
                    if selectedTab == 0 {
                        // Show "Swipe for Type →" when on speech button
                        HStack(spacing: 3) {
                            Text("Swipe for Type")
                                .font(.system(size: 10))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9))
                        }
                        .foregroundColor(.secondary)
                        .padding(.trailing, 10)
                        .padding(.bottom, 5)
                    }
                }
            }
            .frame(height: 100) // Maintain increased height for components
        }
        .onChange(of: selectedTab) { _, newValue in
            viewModel.isTextInputMode = newValue == 1
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
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Using viewModel.metronome properties
                    ForEach(0..<viewModel.metronome.timeSignatureTop, id: \.self) { beatIndex in
                        Circle()
                            .fill(beatIndex == viewModel.metronome.currentBeat ? lightColor : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .shadow(color: beatIndex == viewModel.metronome.currentBeat ? lightColor.opacity(0.8) : .clear,
                                    radius: 10, x: 0, y: 0)
                            .animation(.easeOut(duration: 0.1), value: viewModel.metronome.currentBeat)
                            .frame(width: geometry.size.width / CGFloat(viewModel.metronome.timeSignatureTop))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
            .padding()
            
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

#Preview("Function Notification") {
    VStack(spacing: 20) {
        // Single function notification
        FunctionNotificationView(descriptions: [
            "Changed tempo to 120 BPM"
        ])
        
        // Multiple function notifications
        FunctionNotificationView(descriptions: [
            "Started the metronome",
            "Changed tempo to 100 BPM",
            "Changed sound to Bass Drum"
        ])
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Metronome View with Notification") {
    ZStack(alignment: .top) {
        MetronomeView(compiler: CompilerManager())
        
        // Show a mock notification on top
        FunctionNotificationView(descriptions: [
            "Started the metronome",
            "Changed tempo to 100 BPM"
        ])// Position it where it would normally appear
        .padding(.top, 600)
        .zIndex(1)
    }
}
