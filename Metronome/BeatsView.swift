//  Copyright © 2025 Compiler, Inc. All rights reserved.

import SwiftUI

struct BeatsView: View {
    private let lightColor: Color
    private let timeSignatureTop: Int
    private let currentBeat: Int
    
    init(lightColor: Color, timeSignatureTop: Int, currentBeat: Int) {
        self.lightColor = lightColor
        self.timeSignatureTop = timeSignatureTop
        self.currentBeat = currentBeat
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<timeSignatureTop, id: \.self) { beatIndex in
                    Circle()
                        .fill(beatIndex == currentBeat ? lightColor : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .shadow(color: beatIndex == currentBeat ? lightColor.opacity(0.8) : .clear,
                                radius: 10, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.1), value: currentBeat)
                        .frame(width: geometry.size.width / CGFloat(timeSignatureTop))
                }
            }
        }
        .frame(height: 50)
    }
}

#Preview {
    BeatsView(lightColor: .red, timeSignatureTop: 10, currentBeat: 0)
        .padding()
}
