//
//  CustomNavigationBar.swift
//  RiskTest
//
//  Created by selinay ceylan on 17.09.2025.

import SwiftUI

struct CustomNavigationBar: View {
    var title: String = ""   // Başlık göstermek istersen
    var isCompact: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.leading, 10)
            
            Spacer()
        }
        .frame(height: isCompact ? 50 : 70)
        .background(AppColor.mainColor)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
