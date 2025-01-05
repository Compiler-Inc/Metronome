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
    let id: String = "1561de0c-8e1c-4ace-a870-ac0baecf40f6"
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
    private let apiKey = "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1"
    private let appId = ""

    var manualCommand: String?



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

}
