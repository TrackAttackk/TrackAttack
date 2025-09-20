//
//  AttackCountCard.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct AttackCountCard: View {
    let attackCount: Int
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.fill")
                .font(.title)
                .foregroundColor(AppColor.mainColor)
                .frame(width: 40, height: 40)
                .background(AppColor.mainColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bu Ayki Atak Sayısı")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(attackCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColor.mainColor)
                    
                    Text("atak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                }
                
                if attackCount > 5 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                            .foregroundColor(AppColor.mainColor)
                        Text("Geçen aya göre +2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "chart.bar")
                    .font(.title2)
                    .foregroundColor(AppColor.mainColor)
                    .padding(8)
                    .background(AppColor.mainColor.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
