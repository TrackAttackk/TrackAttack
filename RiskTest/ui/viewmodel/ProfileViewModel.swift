//
//  ProfileViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel {
    
    private let db = Firestore.firestore()
    
    func fetchUserProfile() async -> Profile? {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            print("Kullanıcı oturumu yok!")
            return nil
        }
        
        do {
            let doc = try await db.collection("profiles").document(uid).getDocument()
            
            if let data = doc.data() {
                return Profile(
                    uid: uid,
                    email: email,
                    name: data["name"] as? String ?? "",
                    age: data["age"] as? Int ?? 0,
                    gender: data["gender"] as? String ?? "",
                    smoking: data["smoking"] as? Bool ?? false,
                    familyHeartDisease: data["familyHeartDisease"] as? Bool ?? false,
                    attackCount: data["attackCount"] as? Int ?? 0
                )
            } else {
                return Profile(uid: uid, email: email)
            }
        } catch {
            print("Firestore okuma hatası: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveUserProfile(_ profile: Profile) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "email": profile.email,
            "name": profile.name,
            "age": profile.age,
            "gender": profile.gender,
            "smoking": profile.smoking,
            "familyHeartDisease": profile.familyHeartDisease,
            "attackCount": profile.attackCount
        ]
        
        do {
            try await db.collection("profiles").document(uid).setData(data)
            print("Profil başarıyla kaydedildi.")
        } catch {
            print("Firestore kaydetme hatası: \(error.localizedDescription)")
        }
    }
}
