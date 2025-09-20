//
//  StaticsRowView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct StatisticsRowView: View {
    let viewModel: AttackHistoryViewModel
    
    var body: some View {
        let stats = viewModel.getStatistics()
        
        HStack(spacing: 20) {
            StatisticItemView(
                title: "Toplam",
                value: "\(stats.totalAttacks)",
                icon: "number.circle.fill",
                color: .blue
            )
            
            StatisticItemView(
                title: "Ort. Şiddet",
                value: String(format: "%.1f/10", stats.averageSeverity * 10),
                icon: "heart.fill",
                color: .red
            )
            
            StatisticItemView(
                title: "Ana Tetikleyici",
                value: stats.mostCommonTrigger,
                icon: "exclamationmark.triangle.fill",
                color: .orange
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
