//
//  ContentView.swift
//  RiskTest
//
//  Created by selinay ceylan on 16.09.2025.
//

import SwiftUI
import FirebaseAuth

struct AddAttackView: View {
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var sure: String = ""
    @State private var siddetSeviyesi: Double = 0.5
    @State private var ekNotlar: String = ""
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    
    @State private var isStresSelected: Bool = false
    @State private var isEgzersizSelected: Bool = false
    @State private var isUykusuzlukSelected: Bool = false
    @State private var isKahveSelected: Bool = false
    @State private var isDigerSelected: Bool = false
    
    var viewModel = AddAttackViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 35) {
                    
                    // Tarih ve Saat
                    VStack(alignment: .leading) {
                        Text("Tarih ve Saat").font(.title3).bold()
                        Button(action: { showingDatePicker = true }) {
                            HStack {
                                Text(formatDateForDisplay(selectedDate))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .frame(height: 45)
                        }
                    }
                    
                    // Süre
                    VStack(alignment: .leading) {
                        Text("Süre").font(.title3).bold()
                        TextField("Dakika", text: $sure)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .frame(height: 45)
                            .keyboardType(.numberPad)
                    }
                    
                    // Şiddet Seviyesi
                    VStack(alignment: .leading) {
                        Text("Şiddet Seviyesi").font(.title3).bold()
                        
                        Slider(value: $siddetSeviyesi, in: 0...1)
                            .accentColor(AppColor.mainColor)
                        
                        HStack {
                            Text("Hafif").font(.caption)
                            Spacer()
                            Text("Orta").font(.caption)
                            Spacer()
                            Text("Şiddetli").font(.caption)
                            Spacer()
                            Text("Kritik").font(.caption)
                        }
                        .padding(.horizontal)
                        
                        let severityValue = Int(siddetSeviyesi * 10)
                        let severityBackground = RoundedRectangle(cornerRadius: 10).fill(AppColor.mainColor.opacity(0.5))
                        
                        Text("Şiddet seviyesi: \(severityValue)/10")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 100)
                            .background(severityBackground)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 25)
                    }
                    
                    // Tetikleyici Faktörler
                    VStack(alignment: .leading) {
                        Text("Tetikleyici Faktörler").font(.title3).bold()
                        
                        HStack {
                            FactorButton(text: "Stres", emoji: "😔", isSelected: $isStresSelected)
                            FactorButton(text: "Egzersiz", emoji: "💪", isSelected: $isEgzersizSelected)
                            FactorButton(text: "Uykusuzluk", emoji: "😴", isSelected: $isUykusuzlukSelected)
                        }
                        
                        HStack {
                            FactorButton(text: "Kahve", emoji: "☕", isSelected: $isKahveSelected)
                            FactorButton(text: "Diğer", emoji: "➕", isSelected: $isDigerSelected)
                        }
                    }
                    
                    // Ek Notlar
                    VStack(alignment: .leading) {
                        Text("Ek Notlar").font(.title3).bold()
                        
                        let textEditorBackground = RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
                        
                        TextEditor(text: $ekNotlar)
                            .padding(5)
                            .background(textEditorBackground)
                            .frame(minHeight: 80, maxHeight: 120)
                    }
                    
                    // Default iOS Button
                    Button("Atağı Kaydet") {
                        Task { await saveAttack() }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.mainColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                // Logo
                ToolbarItem(placement: .principal) {
                    Image("trackattack")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Tarih ve Saat Seçin",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Tarih ve Saat Seçin")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("İptal") {
                            showingDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Tamam") {
                            showingDatePicker = false
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(AppColor.mainColor)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Atak Kaydedildi", isPresented: $showingSaveAlert) {
            Button("Tamam") { dismiss() }
        } message: {
            Text(saveMessage)
        }
    }
    
    // MARK: - Fonksiyonlar
    private func saveAttack() async {
        let tetikleyiciler = [
            isStresSelected ? "Stres" : nil,
            isEgzersizSelected ? "Egzersiz" : nil,
            isUykusuzlukSelected ? "Uykusuzluk" : nil,
            isKahveSelected ? "Kahve" : nil,
            isDigerSelected ? "Diğer" : nil
        ].compactMap { $0 }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: selectedDate)
                
        let success = await viewModel.saveAttack(
            tarihSaat: formattedDate,
            sure: Int(sure) ?? 0,
            siddetSeviyesi: siddetSeviyesi,
            tetikleyiciFaktorler: tetikleyiciler,
            ekNotlar: ekNotlar
        )
        
        if success {
            resetForm()
            saveMessage = "Atak başarıyla kaydedildi! Anasayfaya yönlendiriliyorsunuz..."
            showingSaveAlert = true
        } else {
            saveMessage = "Atak kaydedilirken bir hata oluştu. Lütfen tekrar deneyin."
            showingSaveAlert = true
        }
    }
    
    private func resetForm() {
        selectedDate = Date()
        sure = ""
        siddetSeviyesi = 0.5
        ekNotlar = ""
        isStresSelected = false
        isEgzersizSelected = false
        isUykusuzlukSelected = false
        isKahveSelected = false
        isDigerSelected = false
    }
    
    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

#Preview {
    AddAttackView()
}
