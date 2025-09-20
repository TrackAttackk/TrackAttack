//
//  HomeViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var riskLevel: String = "Hesaplanıyor..."
    @Published var heartRate: Int = 80
    @Published var isLoadingRisk: Bool = false

    private let authViewModel: AuthenticationViewModel
    private let db = Firestore.firestore()
    
    @Published var healthKitManager = HealthKitManager()
    
    private let notificationManager = NotificationManager.shared
    
    private var previousRiskLevel: String = ""

    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        
        notificationManager.requestNotificationPermission()
        notificationManager.setupNotificationActions()
        
        healthKitManager.requestAuthorization()
        
        fetchUserName()
        fetchHeartRate()
        
        fetchPreviousRiskLevel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.calculateRiskLevel()
        }
    }
    
    func fetchPreviousRiskLevel() {
        guard let userId = authViewModel.currentUserId else { return }
        
        let docRef = db.collection("profiles").document(userId)
        docRef.getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let risk = data["riskLevel"] as? String {
                DispatchQueue.main.async {
                    self?.previousRiskLevel = risk
                }
            }
        }
    }

    func fetchUserName() {
        guard let userId = authViewModel.currentUserId else {
            userName = "Kullanıcı"
            return
        }

        let docRef = db.collection("profiles").document(userId)
        docRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Kullanıcı adı alınamadı: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.userName = "Kullanıcı" }
                return
            }

            if let data = snapshot?.data(), let name = data["name"] as? String {
                DispatchQueue.main.async { self?.userName = name }
            } else {
                DispatchQueue.main.async { self?.userName = "Kullanıcı" }
            }
        }
    }

    func fetchHeartRate() {
        guard let userId = authViewModel.currentUserId else { return }
        let docRef = db.collection("profiles").document(userId)
        docRef.getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let rate = data["heartRate"] as? Int {
                DispatchQueue.main.async { self?.heartRate = rate }
            }
        }
    }
    
    func calculateRiskLevel() {
        guard let userId = authViewModel.currentUserId else {
            riskLevel = "Kullanıcı bulunamadı"
            return
        }
        
        isLoadingRisk = true
        
        let docRef = db.collection("profiles").document(userId)
        docRef.getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoadingRisk = false
                
                if let error = error {
                    print("Profil verisi alınamadı: \(error.localizedDescription)")
                    self?.riskLevel = "Veri alınamadı"
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self?.riskLevel = "Profil bulunamadı"
                    return
                }
                
                let userProfile = Profile(
                    name: data["name"] as? String ?? "",
                    age: data["age"] as? Int ?? 30,
                    gender: data["gender"] as? String ?? "Erkek",
                    smoking: data["smoking"] as? Bool ?? false,
                    familyHeartDisease: data["familyHeartDisease"] as? Bool ?? false,
                    attackCount: data["attackCount"] as? Int ?? 0
                )
                
                let predictedRisk = self?.healthKitManager.predictHeartRisk(userProfile: userProfile) ?? "Hesaplanamadı"
                
                if let self = self, !self.previousRiskLevel.isEmpty {
                    self.notificationManager.sendRiskIncreaseNotification(
                        from: self.previousRiskLevel,
                        to: predictedRisk
                    )
                }
                
                self?.previousRiskLevel = self?.riskLevel ?? ""
                self?.riskLevel = predictedRisk
                
                self?.saveRiskLevelToFirebase(risk: predictedRisk)
            }
        }
    }
    
    private func saveRiskLevelToFirebase(risk: String) {
        guard let userId = authViewModel.currentUserId else { return }
        
        let docRef = db.collection("profiles").document(userId)
        docRef.updateData(["riskLevel": risk]) { error in
            if let error = error {
                print("Risk seviyesi kaydedilemedi: \(error.localizedDescription)")
            } else {
                print("Risk seviyesi başarıyla kaydedildi: \(risk)")
            }
        }
    }

    func measureHeartRate() {
        heartRate = Int.random(in: 60...110)
        
        if heartRate > 100 || heartRate < 60 {
            notificationManager.sendCriticalHeartRateAlert(heartRate: heartRate)
        }
        
        healthKitManager.fetchAllHealthData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.calculateRiskLevel()
        }
    }
    
    func refreshRiskLevel() {
        healthKitManager.fetchAllHealthData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.calculateRiskLevel()
        }
    }

    func signOut() {
        authViewModel.signOut()
    }
}
