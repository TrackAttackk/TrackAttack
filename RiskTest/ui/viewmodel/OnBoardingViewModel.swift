//
//  OnBoardingViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class OnBoardingViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    
    func saveUserData(name: String,
                      age: Int,
                      gender: String,
                      smoking: Bool?,
                      familyHeartDisease: Bool?,
                      attackCount: Int) async {
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Hata: Kullanıcı oturumu yok!")
            return
        }
        
        let data: [String: Any] = [
            "email": userEmail,
            "name": name,
            "age": age,
            "gender": gender,
            "smoking": smoking ?? false,
            "familyHeartDisease": familyHeartDisease ?? false,
            "attackCount": attackCount
        ]
        
        do {
            let uid = Auth.auth().currentUser!.uid
            try await db.collection("profiles").document(uid).setData(data)
            print("Kullanıcı verisi başarıyla kaydedildi.")
        } catch {
            print("Firestore kaydetme hatası: \(error.localizedDescription)")
        }
    }
}
