//
//  DLMViewModel.swift
//  Metronome
//
//  Created by Aurelius Prochazka on 1/6/25.
//

import Foundation

@Observable
class DLMViewModel {
    
    var processingSteps: [ProcessingStep] = []
    
    public func addStep(_ text: String) {
        processingSteps.append(ProcessingStep(text: text, isComplete: false))
    }

    public func completeLastStep() {
        if let lastIndex = processingSteps.indices.last {
            processingSteps[lastIndex].isComplete = true
        }
    }
    
}
