//
//  AttackDetailSheet.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

struct AttackDetailSheet: View {
    let attack: AttackModel
    let viewModel: AttackHistoryViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 15) {
                            Text(formatDetailDate(attack.tarihSaat))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text(attack.severityText)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(severityColor)
                                )
                            
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(riskColor)
                                Text("Risk Seviyesi: \(riskText)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(riskColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading, spacing: 15) {
                            DetailRow(icon: "clock.fill", title: "Süre", value: attack.durationText, color: .blue)
                            DetailRow(icon: "heart.fill", title: "Şiddet", value: attack.severityLevel, color: .red)
                            
                            if !attack.tetikleyiciFaktorler.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text("Tetikleyici Faktörler")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                    }
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(attack.tetikleyiciFaktorler, id: \.self) { trigger in
                                            HStack {
                                                Image(systemName: triggerIcon(for: trigger))
                                                    .foregroundColor(.orange)
                                                Text(trigger)
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.orange.opacity(0.1))
                                            )
                                        }
                                    }
                                }
                            }
                            
                            if !attack.ekNotlar.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.secondary)
                                        Text("Notlar")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                    }
                                    
                                    Text(attack.ekNotlar)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Öneriler")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            
                            Text(recommendationText)
                                .font(.body)
                                .foregroundColor(.black)
                                .lineLimit(nil)
                            
                            if attack.severityType == "severe" || attack.severityType == "critical" {
                                Button(action: {
                                    if let phoneURL = URL(string: "tel://112") {
                                        UIApplication.shared.open(phoneURL)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("Acil Yardım İçin Ara (112)")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(riskColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Atak Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sil") {
                        showDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(AppColor.mainColor)
                }
            }
        }
        .alert("Atak Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await viewModel.deleteAttack(attack)
                    dismiss()
                }
            }
        } message: {
            Text("Bu atağı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
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
    
    private var riskColor: Color {
        switch attack.severityType {
        case "mild": return .green
        case "moderate": return .orange
        case "severe", "critical": return .red
        default: return .gray
        }
    }
    
    private var riskText: String {
        switch attack.severityType {
        case "mild": return "Düşük Risk"
        case "moderate": return "Orta Risk"
        case "severe", "critical": return "Yüksek Risk"
        default: return "Belirsiz"
        }
    }
    
    private var recommendationText: String {
        switch attack.severityType {
        case "mild": return "Normal aktivitelerinize devam edebilirsiniz. Tetikleyici faktörleri not alın."
        case "moderate": return "Tetikleyici faktörleri kontrol edin. Sık tekrar ederse doktorunuza danışın."
        case "severe", "critical": return "Acil olarak doktorunuza başvurun veya en yakın sağlık kuruluşuna gidin."
        default: return "Doktorunuza danışın."
        }
    }
    
    private func triggerIcon(for trigger: String) -> String {
        switch trigger.lowercased() {
        case "kahve": return "cup.and.saucer.fill"
        case "çay": return "cup.and.saucer"
        case "stres": return "brain.head.profile"
        case "egzersiz": return "figure.run"
        case "uykusuzluk": return "moon.zzz.fill"
        case "alkol": return "wineglass.fill"
        case "anksiyete": return "heart.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func formatDetailDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd MMMM yyyy, HH:mm"
            formatter.locale = Locale(identifier: "tr_TR")
            return formatter.string(from: date)
        }
        return dateString
    }
}
