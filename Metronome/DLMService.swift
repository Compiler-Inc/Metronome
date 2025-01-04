import Foundation
import AudioKit

// Response model
struct DLMCommand: Codable {
    let command: String
    let args: CommandArgs?
}

struct CommandArgs: Codable {
    let bpm: Double?
    let duration: Double?
    let sound: String?
    let count: Int?
}

struct CurrentState: Codable {
    let bpm: Double
}
// Request model
struct DLMRequest: Codable {
    let id: String = "5147f591-70ce-4d17-901e-664ffe24f77a"
    let prompt: String
    let current_state: CurrentState
}

enum MetronomeCommand {
    case play
    case stop
    case setTempo(bpm: Double)
    case rampTempo(bpm: Double, duration: Double)
    case changeSound(sound: String)
    case setDownBeat(sound: String)
    case setUpBeat(sound: String)
    case setGapMeasures(count: Int)
    case noOp

    static func from(_ command: DLMCommand) -> MetronomeCommand? {
        switch command.command {
        case "play":
            return .play
        case "stop":
            return .stop
        case "setTempo":
            guard let bpm = command.args?.bpm else { return nil }
            return .setTempo(bpm: bpm)
        case "rampTempo":
            guard let bpm = command.args?.bpm else { return nil }
            guard let duration = command.args?.duration else { return nil }
            return .rampTempo(bpm: bpm, duration: duration)
        case "changeSound":
            guard let sound = command.args?.sound else { return nil }
            return .changeSound(sound: sound)
        case "setDownBeat":
            guard let sound = command.args?.sound else { return nil }
            return .setDownBeat(sound: sound)
        case "setUpBeat":
            guard let sound = command.args?.sound else { return nil }
            return .setUpBeat(sound: sound)
        case "setGapMeasures":
            guard let count = command.args?.count else { return nil }
            return .setGapMeasures(count: count)
        default:
            return nil
        }
    }
}

struct ProcessingStep: Identifiable, Hashable {
    let id = UUID()
    let text: String
    var isComplete: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class DLMService {
    private let baseURL = "http://backend.compiler.inc/function-call"
    private let apiKey = "890a192daeeb1bf8aa9abd11fc17c605399b0a5e708ef0c971f29e47a9cba20e"
    private let appId = ""
    var processingSteps: [ProcessingStep] = []
    var manualCommand: String?

    private func addStep(_ text: String) {
        processingSteps.append(ProcessingStep(text: text, isComplete: false))
    }

    private func completeLastStep() {
        if let lastIndex = processingSteps.indices.last {
            processingSteps[lastIndex].isComplete = true
        }
    }

    func processCommand(_ content: String, for metro: Metronome) async throws -> [DLMCommand] {
        print("🚀 Starting processCommand with content: \(content)")
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL: \(baseURL)")
            throw URLError(.badURL)
        }
        print("✅ URL created: \(url)")

        let request = DLMRequest(
            prompt: content,
            current_state: CurrentState(bpm: metro.tempo)
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(request)
        urlRequest.httpBody = jsonData
        
        print("📤 Request Headers:", urlRequest.allHTTPHeaderFields ?? [:])
        print("📦 Request Body:", String(data: jsonData, encoding: .utf8) ?? "nil")
        
        addStep("Sending request to DLM")
        print("⏳ Starting network request...")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("📥 Response received")
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Status code: \(httpResponse.statusCode)")
            print("🔍 Response headers: \(httpResponse.allHeaderFields)")
        }
        print("📄 Response body: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        print("Attempting to decode: \(String(data: data, encoding: .utf8) ?? "nil")")
        do {
            let commands = try JSONDecoder().decode([DLMCommand].self, from: data)
            print("✅ Decoded response: \(commands)")
            return commands
        } catch {
            print("❌ Decoding error: \(error)")
            throw error
        }
    }

    func executeCommands(_ commands: [DLMCommand], metronome: Metronome) async throws {
        addStep("Executing commands")
        print("🎯 DLM executing commands: \(commands)")
        completeLastStep()
        
        for command in commands {
            print("⚡️ Processing command: \(command)")
            guard let metronomeCommand = MetronomeCommand.from(command) else {
                print("❌ Failed to parse command: \(command)")
                continue
            }
            print("✅ Parsed command: \(metronomeCommand)")

            switch metronomeCommand {
            case .play:
                addStep("Starting metronome")
                metronome.sequencer.play()
                completeLastStep()

            case .stop:
                addStep("Stopping metronome")
                metronome.sequencer.stop()
                completeLastStep()

            case .setTempo(let bpm):
                addStep("Setting tempo to \(bpm) BPM")
                metronome.tempo = bpm
                completeLastStep()

            case .rampTempo(let bpm, let duration):
                addStep("Ramping tempo to \(bpm) BPM over \(duration) seconds")
                metronome.rampTempo(bpm: bpm, duration: duration)
                completeLastStep()

            case .changeSound(let sound):
                addStep("Setting sound to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    metronome.note = MIDINoteNumber(note)
                }
                completeLastStep()
      
            case .setDownBeat(let sound):
                addStep("Setting downbeat to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    metronome.startingNote = MIDINoteNumber(note)
                }
                completeLastStep()

            case .setUpBeat(let sound):
                addStep("Setting upbeat to \(sound)")
                let s = GiantSound.allCases.first(where: {$0.description == sound})
                if let note = s?.rawValue {
                    metronome.accentNote = MIDINoteNumber(note)
                }
                completeLastStep()

            case .setGapMeasures(let count):
                addStep("Setting gap measures to \(count)")
                metronome.gapMeasureCount = count
                completeLastStep()
            
            case .noOp:
                addStep("NoOp")
                print("⚪️ NoOp command received")
                completeLastStep()
            }
        }
        print("✨ Finished executing all commands")
    }
}

