//
//  AttackCardView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct AttackCardView: View {
    let attack: AttackModel
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Circle()
                    .fill(severityColor)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(severityColor.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(formatDate(attack.tarihSaat))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(attack.severityText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(severityColor)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("Süre: \(attack.durationText)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !attack.tetikleyiciFaktorler.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Tetikleyici: \(attack.triggersText)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("Şiddet: \(attack.severityLevel)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var severityColor: Color {
        switch attack.severityType {
        case "mild": return .green
        case "moderate": return .orange
        case "severe": return .red
        case "critical": return .purple
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd MMM, HH:mm"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: date)
        }
        return dateString
    }
}
