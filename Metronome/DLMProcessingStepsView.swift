//
//  DLMProcessingStepsView.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import SwiftUI

struct DLMProcessingStepsView: View {
    
    var metronome: Metronome
    
    var body: some View {
        // Processing Steps Area
        VStack(alignment: .leading, spacing: 4) {
            if !metronome.processingSteps.isEmpty {
            Text("DLM Output")
                .foregroundColor(DLMColors.primary75)
                    .font(.caption)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(metronome.processingSteps) { step in
                        HStack {
                            Text(step.text)
                                .foregroundColor(DLMColors.primary75)

                            Spacer()

                            if step.isComplete {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    DLMProcessingStepsView(metronome: Metronome())
}
