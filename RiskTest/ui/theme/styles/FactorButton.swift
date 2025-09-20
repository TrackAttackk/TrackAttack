//
//  FactorButton.swift
//  RiskTest
//
//  Created by selinay ceylan on 17.09.2025.
//

import Foundation
import SwiftUI


struct FactorButton: View {
    let text: String
    let emoji: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            VStack(spacing: 5) {
                Text(emoji)
                    .font(.title3)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center) // 👈 yazılar ortalansın
            }
            .frame(width: 120, height: 100) // 👈 kare boyut
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? AppColor.mainColor.opacity(0.8) : AppColor.mainColor.opacity(0.5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}
