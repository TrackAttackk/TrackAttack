//
//  AuthenticationViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//



import Foundation
import FirebaseAuth

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var isNewUser = false
    
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    
    @Published var agreeToTerms = false
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email ve şifre alanları zorunludur"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Geçerli bir email adresi giriniz"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getLocalizedErrorMessage(error) ?? error.localizedDescription
                    return
                }
                
                self?.isNewUser = false
                self?.errorMessage = nil
                self?.isAuthenticated = true
                
                print("Kullanıcı başarıyla giriş yaptı: \(self?.email ?? "")")
                print("isNewUser: false (Sign In)")
            }
        }
    }
    
    func signUp() {
        guard validateSignUpFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getLocalizedErrorMessage(error) ?? error.localizedDescription
                    return
                }
                
                if let user = result?.user {
                    self?.isNewUser = true
                    print("Yeni kullanıcı oluşturuldu - ID: \(user.uid)")
                    print("Hesap oluşturma tarihi: \(user.metadata.creationDate ?? Date())")
                } else {
                    self?.isNewUser = false
                }
                
                self?.errorMessage = nil
                self?.isAuthenticated = true
                print("Kullanıcı başarıyla kayıt oldu: \(self?.email ?? "")")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            isNewUser = false
            clearFields()
            print("Kullanıcı çıkış yaptı")
        } catch {
            errorMessage = "Çıkış yapılırken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Şifre sıfırlama için email adresinizi giriniz"
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Geçerli bir email adresi giriniz"
            return
        }
        
        isLoading = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getLocalizedErrorMessage(error) ?? error.localizedDescription
                    return
                }
                
                self?.errorMessage = nil
                print("Şifre sıfırlama emaili gönderildi: \(self?.email ?? "")")
            }
        }
    }
    
    func checkAuthenticationStatus() {
        if let _ = Auth.auth().currentUser {
            isAuthenticated = true
            isNewUser = false
            print("Mevcut kullanıcı bulundu - HomeView'a yönlendirilecek")
        } else {
            isAuthenticated = false
            isNewUser = false
            print("Kullanıcı bulunamadı - SignInView'a yönlendirilecek")
        }
    }
    
    private func validateSignUpFields() -> Bool {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Tüm alanlar zorunludur"
            return false
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Geçerli bir email adresi giriniz"
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Şifreler eşleşmiyor"
            return false
        }
        
        guard agreeToTerms else {
            errorMessage = "Şartlar ve koşulları kabul etmelisiniz"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func getLocalizedErrorMessage(_ error: Error) -> String {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse: return "Bu email adresi zaten kullanımda"
            case .weakPassword: return "Şifre çok zayıf. Daha güçlü bir şifre seçin"
            case .invalidEmail: return "Geçersiz email adresi"
            case .userNotFound: return "Bu email ile kayıtlı kullanıcı bulunamadı"
            case .wrongPassword: return "Hatalı şifre"
            case .tooManyRequests: return "Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin"
            case .userDisabled: return "Bu hesap devre dışı bırakılmış"
            case .networkError: return "İnternet bağlantınızı kontrol edin"
            default: return "Bilinmeyen hata oluştu: \(error.localizedDescription)"
            }
        }
        return error.localizedDescription
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        showPassword = false
        showConfirmPassword = false
        agreeToTerms = false
    }
    
    func togglePasswordVisibility() { showPassword.toggle() }
    func toggleConfirmPasswordVisibility() { showConfirmPassword.toggle() }
    func toggleTermsAgreement() { agreeToTerms.toggle() }
}
