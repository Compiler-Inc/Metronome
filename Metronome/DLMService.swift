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
    let id: String = "5c58a359-51b4-4b04-940f-8aba48e12f73"
    let prompt: String
    let current_state: CurrentState
    

}

struct CurrentState: Codable {
    let bpm: Double
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
    private let baseURL = "http://backend.compiler.inc/function-call"
    private let authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0LXVzZXIiLCJpYXQiOjE3MzQ0MDEwNTksImV4cCI6MTczNDQwNDY1OX0.9NDKQuukKCK__oO5KqMAgXGsM2Gomim4RffF-ecBSHw"
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
        print("🚀 Starting processCommand with content: \(content)")
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL: \(baseURL)")
            throw URLError(.badURL)
        }
        print("✅ URL created: \(url)")

        let request = DLMRequest(
            prompt: content,
            current_state: CurrentState(bpm: 1) // You might want to get this from metronome
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
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
        
        let response2 = try JSONDecoder().decode(DLMResponse.self, from: data)
        print("✅ Decoded response: \(response2)")

        completeLastStep()
        return response2
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

