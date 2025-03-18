//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI
import AuthenticationServices
import CompilerSwiftAI
import AVFoundation

@main
struct MetronomeApp: App {
    @State private var compiler = CompilerManager()
    @State private var currentNonce: String?
    
    init() {
        setupAudioSession()
    }

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
                                    try await compiler.client.handleSignInWithApple(result, nonce: currentNonce)
                                    compiler.isAuthenticated = true
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
    // Add private function for AVAudioSession setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error: can't change AVAudioSession: \(error.localizedDescription)")
        }
    }
}
