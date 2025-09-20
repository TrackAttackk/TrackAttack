//
//  HomeView.swift
//  RiskTest
//
//  Created by selinay ceylan on 17.09.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    private let horizontalPadding: CGFloat = 16

    init(authViewModel: AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Merhaba, \(viewModel.userName)!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                            .padding(.horizontal, horizontalPadding)

                        Image("home")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipped()
                            .cornerRadius(15)
                            .padding(.horizontal, horizontalPadding)

                        HStack {
                            Text("Mevcut Risk Durumu")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            Text(viewModel.riskLevel)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(AppColor.mainColor)
                        .cornerRadius(15)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 10)

                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kalp Atış Hızı")
                                    .font(.headline)

                                Text("\(viewModel.heartRate) bpm")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)

                                Button(action: viewModel.measureHeartRate) {
                                    Text("Ölçüm")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(AppColor.mainColor.opacity(0.8))
                                        .cornerRadius(18)
                                }
                            }

                            Spacer()

                            Image("heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .padding(.trailing, 10)
                        }
                        .padding()
                        .background(AppColor.mainColor.opacity(0.3))
                        .cornerRadius(15)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 10)

                        NavigationLink(destination: AddAttackView()) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Atak Kaydet")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColor.mainColor.opacity(0.6))
                            .cornerRadius(10)
                        }
                        .frame(height: 80)
                        .padding(.horizontal, horizontalPadding)

                        NavigationLink(destination: BreathingExerciseView()) {
                            HStack {
                                Image(systemName: "wind")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Nefes Egzersizi")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColor.mainColor.opacity(0.6))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, horizontalPadding)

                        Spacer()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColor.mainColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("trackattack")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    }
                }
            }
            .tabItem {
                Label("Anasayfa", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                AttackHistoryView()
                    .navigationTitle("Geçmiş")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(AppColor.mainColor, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.light, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image("trackattack")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                        }
                    }
            }
            .tabItem {
                Label("Geçmiş", systemImage: "list.bullet.rectangle.fill")
            }
            .tag(1)

            NavigationStack {
                ChatBotView()
                    .navigationTitle("Asistan")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(AppColor.mainColor, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.light, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image("trackattack")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                        }
                    }
            }
            .tabItem {
                Label("Asistan", systemImage: "sparkle.magnifyingglass")
            }
            .tag(2)

            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(AppColor.mainColor, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.light, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image("trackattack")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                viewModel.signOut() 
                            }) {
                                Image(systemName: "power")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }

                    }
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(3)
        }
        .accentColor(AppColor.mainColor)
    }
}

#Preview {
    HomeView(authViewModel: AuthenticationViewModel())
}
