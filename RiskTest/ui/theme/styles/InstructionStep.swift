//
//  InstructionStep.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 15) {
            Text("\(number)")
                .font(.headline).fontWeight(.bold).foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(AppColor.mainColor.opacity(0.6)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).fontWeight(.semibold).foregroundColor(.black)
                Text(description).font(.subheadline).foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.mainColor.opacity(isActive ? 0.1 : 0.05))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.mainColor.opacity(isActive ? 0.3 : 0.1), lineWidth: 1))
        )
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}
