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
