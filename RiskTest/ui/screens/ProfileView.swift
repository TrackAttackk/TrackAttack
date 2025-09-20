//
//  ProfileView.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var profile = Profile()
    var viewModel = ProfileViewModel()
    
    @State private var showingNameEdit = false
    @State private var showingAgeEdit = false
    @State private var tempName = ""
    @State private var tempAge = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                profileHeader
                
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        ProfileCard(
                            icon: "person.fill",
                            title: "İsim",
                            value: profile.name,
                            iconColor: AppColor.mainColor,
                            onEdit: {
                                tempName = profile.name
                                showingNameEdit = true
                            }
                        )
                        
                        ProfileCard(
                            icon: "calendar",
                            title: "Yaş",
                            value: "\(profile.age) yaşında",
                            iconColor: AppColor.mainColor,
                            onEdit: {
                                tempAge = String(profile.age)
                                showingAgeEdit = true
                            }
                        )
                    }
                    
                    HStack(spacing: 15) {
                        ToggleProfileCard(
                            icon: "smoke.fill",
                            title: "Sigara",
                            isOn: $profile.smoking,
                            iconColor: AppColor.mainColor
                        )
                        .onChange(of: profile.smoking) { _ in
                            Task { await viewModel.saveUserProfile(profile) }
                        }
                        
                        ToggleProfileCard(
                            icon: "heart.fill",
                            title: "Aile Geçmişi",
                            isOn: $profile.familyHeartDisease,
                            iconColor: AppColor.mainColor
                        )
                        .onChange(of: profile.familyHeartDisease) { _ in
                            Task { await viewModel.saveUserProfile(profile) }
                        }
                    }
                    
                    AttackCountCard(
                        attackCount: profile.attackCount,
                        onEdit: {
                        }
                    )
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            Task {
                if let fetchedProfile = await viewModel.fetchUserProfile() {
                    self.profile = fetchedProfile
                }
            }
        }
        .alert("İsim Düzenle", isPresented: $showingNameEdit) {
            TextField("İsim", text: $tempName)
            Button("İptal", role: .cancel) {}
            Button("Kaydet") {
                if !tempName.isEmpty {
                    profile.name = tempName
                    Task { await viewModel.saveUserProfile(profile) }
                }
            }
        }
        .alert("Yaş Düzenle", isPresented: $showingAgeEdit) {
            TextField("Yaş", text: $tempAge)
                .keyboardType(.numberPad)
            Button("İptal", role: .cancel) {}
            Button("Kaydet") {
                if let age = Int(tempAge), age > 0 && age < 150 {
                    profile.age = age
                    Task { await viewModel.saveUserProfile(profile) }
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColor.mainColor.opacity(0.3), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(String(profile.name.prefix(1)))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: {}) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppColor.mainColor)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .offset(x: 35, y: 35)
            }
            
            VStack(spacing: 5) {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Kalp Sağlığı Takibi")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}



#Preview {
    ProfileView()
}
