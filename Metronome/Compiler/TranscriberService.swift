//
import Foundation
import Transcriber
import Speech

@Observable
class TranscriberService: Transcribable {
    var authStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    public var isRecording: Bool = false
    public var transcriptionComplete: Bool = false
    public var transcribedText: String = ""
    public var rmsValue: Float = 0
    var error: (any Error)?
    public let transcriber: Transcriber?
    private var recordingTask: Task<Void, Never>?
    
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
}
