//
//  ContentView.swift
//  RiskTest
//
//  Created by selinay ceylan on 16.09.2025.
//


import SwiftUI

struct AttackHistoryView: View {
    @StateObject private var viewModel = AttackHistoryViewModel()
    @State private var selectedPeriod = 0
    @State private var showingDetailSheet = false
    @State private var selectedAttack: AttackModel?
    @State private var showDeleteAlert = false
    @State private var attackToDelete: AttackModel?
    
    let periodOptions = AttackHistoryViewModel.FilterPeriod.allCases
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    HStack(spacing: 10) {
                        ForEach(0..<periodOptions.count, id: \.self) { index in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedPeriod = index
                                    Task {
                                        await viewModel.fetchAttacksForPeriod(periodOptions[index])
                                    }
                                }
                            }) {
                                Text(periodOptions[index].title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedPeriod == index ? .white : AppColor.mainColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedPeriod == index ? AppColor.mainColor : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(AppColor.mainColor.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .scaleEffect(selectedPeriod == index ? 1.02 : 1.0)
                            }
                        }
                        Spacer()
                    }
                    
                    if !viewModel.attacks.isEmpty {
                        StatisticsRowView(viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Atacağınız yükleniyor...")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Hata")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Tekrar Dene") {
                            Task {
                                await viewModel.fetchAttacksForPeriod(periodOptions[selectedPeriod])
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColor.mainColor)
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                } else if viewModel.attacks.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("Henüz atak kaydı yok")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Bu zaman aralığında herhangi bir atak kaydedilmedi.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.attacks) { attack in
                                AttackCardView(attack: attack)
                                    .onTapGesture {
                                        selectedAttack = attack
                                        showingDetailSheet = true
                                    }
                                    .contextMenu {
                                        Button("Sil", role: .destructive) {
                                            attackToDelete = attack
                                            showDeleteAlert = true
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                        .padding(.bottom, 100)
                    }
                }
            }
            .padding(.top, 1)
        }
        .task {
            await viewModel.fetchAttacksForPeriod(periodOptions[selectedPeriod])
        }
        .refreshable {
            await viewModel.fetchAttacksForPeriod(periodOptions[selectedPeriod])
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let attack = selectedAttack {
                AttackDetailSheet(attack: attack, viewModel: viewModel)
            }
        }
        .alert("Atak Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                if let attack = attackToDelete {
                    Task {
                        await viewModel.deleteAttack(attack)
                    }
                }
            }
        } message: {
            Text("Bu atağı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
    }
}


#Preview {
    AttackHistoryView()
}

