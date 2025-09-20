//
//  SignInView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var showForgotPassword = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hoşgeldin! 👋")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Sağlık yolculuğunuza devam etmek için giriş yapın.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -20)
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email").font(.headline)
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Şifre").font(.headline)
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                        if viewModel.showPassword {
                            TextField("Şifre", text: $viewModel.password)
                        } else {
                            SecureField("Şifre", text: $viewModel.password)
                        }
                        Button(action: viewModel.togglePasswordVisibility) {
                            Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
      
                HStack {
                    Spacer()
                    Button("Şifremi Unuttum") {
                        showForgotPassword = true
                    }
                    .foregroundColor(AppColor.mainColor)
                    .font(.subheadline)
                }
                

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                

                Button(action: {
                    Task { await MainActor.run { viewModel.signIn() } }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text(viewModel.isLoading ? "Giriş yapılıyor..." : "Giriş Yap")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isLoading ? AppColor.mainColor.opacity(0.7) : AppColor.mainColor)
                    .cornerRadius(25)
                }
                .disabled(viewModel.isLoading)
                
                HStack {
                    Text("Hesabın yok mu?")
                        .foregroundColor(.secondary)
                    NavigationLink(destination: SignUpView().environmentObject(viewModel)) {
                        Text("Kayıt ol")
                            .foregroundColor(AppColor.mainColor)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .alert("Şifre Sıfırlama", isPresented: $showForgotPassword) {
            Button("İptal", role: .cancel) { }
            Button("Gönder") {
                viewModel.resetPassword()
            }
        } message: {
            Text("Email adresinize şifre sıfırlama bağlantısı gönderilecek.")
        }
    }
}
