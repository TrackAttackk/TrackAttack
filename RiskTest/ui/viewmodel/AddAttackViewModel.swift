//
//  AttackViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 19.09.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AddAttackViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    func saveAttack(tarihSaat: String,
                    sure: Int,
                    siddetSeviyesi: Double,
                    tetikleyiciFaktorler: [String],
                    ekNotlar: String) async -> Bool {
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Hata: Kullanıcı oturumu yok!")
            return false
        }
        
        let attackId = UUID().uuidString
        
        do {
            try await db.collection("attacks")
                .document(userEmail)
                .collection("userAttacks")
                .document(attackId)
                .setData([
                    "tarihSaat": tarihSaat,
                    "sure": sure,
                    "siddetSeviyesi": siddetSeviyesi,
                    "tetikleyiciFaktorler": tetikleyiciFaktorler,
                    "ekNotlar": ekNotlar,
                    "email": userEmail,
                    "createdAt": FieldValue.serverTimestamp()
                ])
            print("Atak başarıyla kaydedildi: \(attackId)")
            return true
        } catch {
            print("Firestore kaydetme hatası: \(error.localizedDescription)")
            return false
        }
    }
}
