//
//  GenderOptionView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct GenderOptionView: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                Text(title).font(.headline)
            }
            .padding()
            .background(isSelected ? AppColor.mainColor.opacity(0.7) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
