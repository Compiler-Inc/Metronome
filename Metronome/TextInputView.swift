//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct TextInputView: View {
    @Binding var promptText: String
    var onSend: () -> Void
    var isProcessing: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Send Prompt", text: $promptText)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .focused($isFocused)
            
            Button(action: {
                isFocused = false
                onSend()
            }) {
                if isProcessing {
                    // Show progress spinner when processing
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.0)
                } else {
                    // Show send icon when not processing
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                }
            }
            // Match the height of the text field and set button colors
            .frame(width: 40, height: 40)
            .background(isProcessing ? Color.gray : Color.blue)
            .clipShape(Circle())
            .foregroundColor(.white)
            // Disable button when processing or text is empty
            .disabled(isProcessing || promptText.isEmpty)
        }
        .padding(.horizontal, 16)
    }
}


#Preview {
    TextInputView(promptText: .constant(""), onSend: {}, isProcessing: false)
}

#Preview {
    TextInputView(promptText: .constant(""), onSend: {}, isProcessing: true)
}
