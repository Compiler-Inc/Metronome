import Foundation
import Transcriber
import Speech

@Observable
class TranscriberService: Transcribable {
    var authStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    public var isRecording: Bool = false
    public var transcriptionComplete: Bool = false {
        didSet {
            if transcriptionComplete, let completion = transcriptionCompletion {
                completion(transcribedText)
                transcriptionCompletion = nil
            }
        }
    }
    public var transcribedText: String = ""
    public var rmsValue: Float = 0
    var error: (any Error)?
    public let transcriber: Transcriber?
    private var recordingTask: Task<Void, Never>?
    
    private var transcriptionCompletion: ((String) -> Void)?
    
    init() {
        self.transcriber = Transcriber(config: TranscriberConfiguration(silenceThreshold: 0.01), debugLogging: true)
    }
    
    // Required protocol methods
    public func requestAuthorization() async throws {
        guard let transcriber else {
            throw TranscriberError.noRecognizer
        }
        authStatus = await transcriber.requestAuthorization()
        guard authStatus == .authorized else {
            throw TranscriberError.notAuthorized
        }
    }
    
    public func toggleRecording() {
        guard let transcriber else {
            error = TranscriberError.noRecognizer
            return
        }
        
        if isRecording {
            // Cancel any existing recording task first
            recordingTask?.cancel()
            recordingTask = nil
            
            // Then create a new task to stop the stream
            Task {
                await transcriber.stopStream()
                isRecording = false
                transcriptionComplete = true
            }
        } else {
            // Cancel any existing task first
            recordingTask?.cancel()
            recordingTask = nil
            
            recordingTask = Task {
                do {
                    isRecording = true
                    transcriptionComplete = false
                    let combinedStream = try await transcriber.startStream()
                    
                    for await signal in combinedStream {
                        switch signal {
                            case .transcription(let text):
                                transcribedText = text
                            case .rms(let rms):
                                rmsValue = Float(rms)
                        }
                    }
                    
                    isRecording = false
                    transcriptionComplete = true
                } catch {
                    self.error = error
                    isRecording = false
                }
            }
        }
    }
    public func recordAndTranscribe() async -> String {
        // If already recording, stop and get the result
        if isRecording {
            toggleRecording() // Stop the recording
            // Wait a bit for transcriptionComplete to be set
            try? await Task.sleep(for: .milliseconds(100))
            return transcribedText
        }
        
        // Otherwise start a new recording session
        return await withCheckedContinuation { continuation in
            // Reset the transcribed text when starting a new recording
            transcribedText = ""
            transcriptionComplete = false
            
            // Set the completion handler to resume the continuation
            onTranscriptionComplete { text in
                continuation.resume(returning: text)
            }
            
            // Start recording
            toggleRecording()
        }
    }
    
    public func onTranscriptionComplete(perform action: @escaping (String) -> Void) {
        // If already complete, execute immediately
        if transcriptionComplete {
            action(transcribedText)
            return
        }
        
        // Replace any existing completion handler with the new one
        transcriptionCompletion = action
    }
}
