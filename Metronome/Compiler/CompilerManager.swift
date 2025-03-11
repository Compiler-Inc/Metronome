//  Copyright © 2025 Compiler, Inc. All rights reserved.

import CompilerSwiftAI
import Foundation

@Observable
@MainActor
class CompilerManager {
    
    // MARK: - Properties
    var isAuthenticated = false
    var errorMessage: String?
    var isCheckingAuth = true
    
    /// Our service that talks to the backend
    let client: CompilerClient
    let systemPrompt: String? = nil
    
    
    // MARK: - Init / Deinit
    init() {
        client = CompilerClient(
            appID: "a8fd0b14-489c-49f5-ac54-ccdcfd3710ec",
            configuration: CompilerClient.Configuration(
                streamingChat: .google(.flash),
                enableDebugLogging: true
            )
        )
        // Check auth state on init
        Task {
            do {
                isAuthenticated = try await client.attemptAutoLogin()
            } catch {
                errorMessage = error.localizedDescription
            }
            isCheckingAuth = false
        }
    }
}

extension CompilerManager {
    
    /// Process a voice prompt and return the resulting compiler functions
    /// - Parameter prompt: The transcribed text from the voice input
    /// - Returns: An array of parsed CompilerFunction objects
    func getFunctions(for prompt: String) async throws -> [CompilerFunction] {
        
        // Process the prompt with the backend service and convert to CompilerFunction enums
        let compilerFunctions: [CompilerFunction] = try await client.processFunction(
            prompt: prompt,
            for: MetronomeState(bpm: 120)
        )
        
        print("🤖 Received \(compilerFunctions.count) functions from backend")
        
        // No need to parse raw functions anymore since we're directly decoding to CompilerFunction
        // Add debug logging for each function
        compilerFunctions.forEach { function in
            print("✅ Received function: \(function)")
        }
        
        return compilerFunctions
    
    }
}


