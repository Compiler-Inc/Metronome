//
//  FunctionNotificationView.swift
//  Metronome
//
//  Created by Atharva Vaidya on 3/10/25.
//

import SwiftUI

struct FunctionNotificationView: View {
     let descriptions: [String]

     var body: some View {
         VStack(alignment: .leading, spacing: 6) {
             ForEach(descriptions, id: \.self) { description in
                 Text(description)
                     .font(.system(size: 14, weight: .medium))
                     .padding(.vertical, 12)
                     .padding(.horizontal, 16)
                     .background(
                         RoundedRectangle(cornerRadius: 16)
                             .fill(.ultraThinMaterial)
                     )
                     .overlay(
                         RoundedRectangle(cornerRadius: 16)
                             .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                     )
                     .padding(.horizontal)
                     .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                     .transition(.move(edge: .top).combined(with: .opacity))
             }
             
         }
     }
 }

#Preview {
    FunctionNotificationView(descriptions: ["Setting tempo to 120 BPM", "Setting time signature to 4/4", "Setting meter to 4"])
}
