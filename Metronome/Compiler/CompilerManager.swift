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
    var lastTranscribedText: String = ""
    
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
    func processVoicePrompt(_ prompt: String) async throws -> [CompilerFunction] {
        // Save the last transcribed text
        lastTranscribedText = prompt
        
        // Process the prompt with the backend service
        let functions: [Function<MetronomeParameters>] = try await client.processFunction(
            prompt: prompt,
            for: MetronomeState(bpm: 120)
        )
        
        print("🤖 Received \(functions.count) functions from backend")
        
        // Parse raw functions into our domain-specific CompilerFunction enum
        // Add debug logging for each function
        let compilerFunctions = functions.compactMap { function -> CompilerFunction? in
            print("🎯 Parsing function: \(function)")
            
            guard let parsedFunction = CompilerFunction.from(function) else {
                print("❌ Failed to parse function: \(function)")
                return nil
            }
            
            print("✅ Successfully parsed function: \(parsedFunction)")
            return parsedFunction
        }
        
        print("🎮 Successfully parsed \(compilerFunctions.count) of \(functions.count) functions")
        
        return compilerFunctions
    }
}


