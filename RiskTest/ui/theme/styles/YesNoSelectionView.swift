//
//  YesNoSelectionView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct YesNoSelectionView: View {
    @Binding var selection: Bool?
    let yesText: String
    let noText: String
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: { selection = true }) {
                Text(yesText)
                    .frame(width: 100, height: 64)
                    .background(selection == true ? AppColor.mainColor.opacity(0.7) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.black)
            }
            
            Button(action: { selection = false }) {
                Text(noText)
                    .frame(width: 100, height: 64)
                    .background(selection == false ? AppColor.mainColor.opacity(0.7) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.black)
            }
        }
    }
}
