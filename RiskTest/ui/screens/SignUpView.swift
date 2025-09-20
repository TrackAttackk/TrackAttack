//
//  SignUpView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hesap Oluştur! ❤️")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Kalp sağlığı yolculuğunuza bugün başlayın.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                    
                    if !viewModel.password.isEmpty {
                        HStack {
                            Text("Şifre gücü:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(passwordStrength)
                                .font(.caption)
                                .foregroundColor(passwordStrengthColor)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Şifreyi Onayla").font(.headline)
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                        if viewModel.showConfirmPassword {
                            TextField("Şifreyi Onayla", text: $viewModel.confirmPassword)
                        } else {
                            SecureField("Şifreyi Onayla", text: $viewModel.confirmPassword)
                        }
                        Button(action: viewModel.toggleConfirmPasswordVisibility) {
                            Image(systemName: viewModel.showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if !viewModel.confirmPassword.isEmpty {
                        HStack {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Text(passwordsMatch ? "Şifreler eşleşiyor" : "Şifreler eşleşmiyor")
                                .font(.caption)
                                .foregroundColor(passwordsMatch ? .green : .red)
                        }
                    }
                }
                
                Button(action: viewModel.toggleTermsAgreement) {
                    HStack {
                        Image(systemName: viewModel.agreeToTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.agreeToTerms ? AppColor.mainColor : .secondary)
                        Text("Şartlar ve Koşullar'ı kabul ediyorum")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task { await MainActor.run { viewModel.signUp() } }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text(viewModel.isLoading ? "Hesap oluşturuluyor..." : "Hesap Oluştur")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.agreeToTerms && !viewModel.isLoading
                        ? AppColor.mainColor
                        : AppColor.mainColor.opacity(0.5)
                    )
                    .cornerRadius(25)
                }
                .disabled(!viewModel.agreeToTerms || viewModel.isLoading)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var passwordStrength: String {
        let password = viewModel.password
        if password.count >= 8 &&
            password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
            password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            password.rangeOfCharacter(from: .decimalDigits) != nil {
            return "Güçlü"
        } else if password.count >= 6 {
            return "Orta"
        } else if password.count >= 3 {
            return "Zayıf"
        }
        return "Çok Zayıf"
    }
    
    private var passwordStrengthColor: Color {
        switch passwordStrength {
        case "Güçlü": return .green
        case "Orta": return .orange
        case "Zayıf": return .red
        default: return .red
        }
    }
    
    private var passwordsMatch: Bool {
        !viewModel.password.isEmpty &&
        !viewModel.confirmPassword.isEmpty &&
        viewModel.password == viewModel.confirmPassword
    }
}

