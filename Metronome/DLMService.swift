import Foundation

// Response model
struct DLMResponse: Codable {
    let function_calls: [String]

    func cleanedFunctionCalls() -> [String] {
        return function_calls.map { call in
            call.trimmingCharacters(in: .init(charactersIn: "\""))
        }
    }
}

// Request model
struct DLMRequest: Codable {
    let model: String = "local-model"
    let messages: [Message]
    let temperature: Double = 0.1
    let max_tokens: Int = 64

    struct Message: Codable {
        let role: String = "user"
        let content: String
    }
}

enum DLMCommand {
    case start
    case stop
    case setTempo(bpm: Double)
    case noOp

    static func parse(_ functionCall: String) -> DLMCommand? {
        print("🔍 Parsing function call: \(functionCall)")
        let cleaned = functionCall.trimmingCharacters(in: .init(charactersIn: "\""))
        print("🧹 Cleaned function call: \(cleaned)")
        
        let components = cleaned.split(separator: " ").map(String.init)
        print("📦 Components: \(components)")
        
        guard let function = components.first else {
            print("❌ No function found in components")
            return nil
        }

        switch function {
        case "start":
            print("✅ Parsed start command")
            return .start
        case "stop":
            print("✅ Parsed stop command")
            return .stop
        case "setTempo":
            guard components.count == 2,
                  let bpm = Double(components[1]) else {
                print("❌ Invalid setTempo format or BPM value")
                return nil
            }
            print("✅ Parsed setTempo command with BPM: \(bpm)")
            return .setTempo(bpm: bpm)
        case "noOp":
            print("✅ Parsed noOp command")
            return .noOp
        default:
            print("❌ Unknown command: \(function)")
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
    private let baseURL = "http://localhost:8080/v1/chat/completions"
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

    func processCommand(_ content: String) async throws -> DLMResponse {
        print("Processing command: \(content)")
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        let request = DLMRequest(messages: [.init(content: content)])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        addStep("Sending request to DLM")
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(DLMResponse.self, from: data)
        completeLastStep()
        return response
    }

    func executeCommands(_ commands: [String], metronome: Metronome) async throws {
        addStep("Executing commands")
        print("🎯 DLM executing commands: \(commands)")
        completeLastStep()

        let cleanedCommands = DLMResponse(function_calls: commands).cleanedFunctionCalls()
        print("🧹 Cleaned commands: \(cleanedCommands)")
        
        for command in cleanedCommands {
            print("⚡️ Processing command: \(command)")
            guard let dlmCommand = DLMCommand.parse(command) else {
                print("❌ Failed to parse command: \(command)")
                continue
            }
            print("✅ Parsed command: \(dlmCommand)")

            switch dlmCommand {
            case .start:
                addStep("Starting metronome")
                print("▶️ Starting metronome sequencer")
                metronome.sequencer.play()
                completeLastStep()

            case .stop:
                addStep("Stopping metronome")
                print("⏹️ Stopping metronome sequencer")
                metronome.sequencer.stop()
                completeLastStep()

            case .setTempo(let bpm):
                addStep("Setting tempo to \(bpm) BPM")
                print("🎼 Setting tempo to \(bpm) BPM")
                metronome.tempo = bpm
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

