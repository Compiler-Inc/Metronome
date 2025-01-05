import Foundation
import AudioKit

// Response model
struct DLMCommand: Codable {
    let command: String
    let args: CommandArgs?
}

// Request model
struct DLMRequest: Codable {
    let id: String = "1561de0c-8e1c-4ace-a870-ac0baecf40f6"
    let prompt: String
    let current_state: CurrentState
}

@Observable
class DLMService {
    private let baseURL = "http://backend.compiler.inc/function-call"
    private let apiKey = "371f0e448174ad84a4cfd0af924a1b1638bdf99cfe8e91ad2b1c23df925cb8a1"
    private let appId = ""

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
