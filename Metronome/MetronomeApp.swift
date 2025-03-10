//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import AuthenticationServices
import CompilerSwiftAI

@main
struct MetronomeApp: App {
    @State private var compiler = CompilerManager()
    @State private var currentNonce: String?

    var body: some Scene {
        WindowGroup {
            if compiler.isCheckingAuth {
                ProgressView("Checking authentication ...")
                    .progressViewStyle(.circular)
            } else if compiler.isAuthenticated {
                MetronomeView(compiler: compiler)
            } else {
                VStack {
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = CompilerClient.randomNonceString()
                            currentNonce = nonce
                            request.nonce = CompilerClient.sha256(nonce)
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                do {
                                    compiler.isAuthenticated = try await compiler.client.handleSignInWithApple(result, nonce: currentNonce)
                                } catch {
                                    compiler.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    )
                    .frame(width: 280, height: 45)
                    .signInWithAppleButtonStyle(.white)
                    
                    if let errorMessage = compiler.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
    }
}
