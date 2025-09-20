//
//  AttackHistoryViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AttackHistoryViewModel: ObservableObject {
    @Published var attacks: [AttackModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    enum FilterPeriod: Int, CaseIterable {
        case week = 0
        case month = 1
        case threeMonths = 2
        
        var title: String {
            switch self {
            case .week: return "7 Gün"
            case .month: return "30 Gün"
            case .threeMonths: return "3 Ay"
            }
        }
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    func fetchUserAttacks() async {
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "Kullanıcı oturumu bulunamadı"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("attacks")
                .document(userEmail)
                .collection("userAttacks")
                .order(by: "tarihSaat", descending: true)
                .getDocuments()
            
            let fetchedAttacks = snapshot.documents.compactMap { document in
                AttackModel(documentId: document.documentID, data: document.data())
            }
            
            attacks = fetchedAttacks.sorted { $0.timestamp > $1.timestamp }
            
        } catch {
            errorMessage = "Veriler yüklenirken hata oluştu: \(error.localizedDescription)"
            print("Firebase fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchAttacksForPeriod(_ period: FilterPeriod) async {
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "Kullanıcı oturumu bulunamadı"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -period.days, to: endDate) ?? endDate
        
        do {
            let snapshot = try await db.collection("attacks")
                .document(userEmail)
                .collection("userAttacks")
                .getDocuments()
            
            let fetchedAttacks = snapshot.documents.compactMap { document in
                AttackModel(documentId: document.documentID, data: document.data())
            }
            
            // Tarihleri doğru parse edilenler için filtre uygula
            attacks = fetchedAttacks.filter { attack in
                if let _ = parseDateFromString(attack.tarihSaat) {
                    return attack.timestamp >= startDate && attack.timestamp <= endDate
                } else {
                    return true
                }
            }.sorted { $0.timestamp > $1.timestamp }
            
        } catch {
            errorMessage = "Veriler yüklenirken hata oluştu: \(error.localizedDescription)"
            print("Firebase fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    private func parseDateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        let formats = [
            "dd.MM.yyyy HH:mm",
            "dd.MM.yyyy H:mm",
            "d.MM.yyyy HH:mm",
            "d.M.yyyy HH:mm"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    func deleteAttack(_ attack: AttackModel) async {
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "Kullanıcı oturumu bulunamadı"
            return
        }
        
        do {
            try await db.collection("attacks")
                .document(userEmail)
                .collection("userAttacks")
                .document(attack.documentId)
                .delete()
            
            attacks.removeAll { $0.documentId == attack.documentId }
            
        } catch {
            errorMessage = "Atak silinirken hata oluştu: \(error.localizedDescription)"
            print("Firebase delete error: \(error)")
        }
    }
    
    func getStatistics() -> (totalAttacks: Int, averageSeverity: Double, mostCommonTrigger: String) {
        let totalAttacks = attacks.count
        
        let averageSeverity = attacks.isEmpty ? 0.0 :
            attacks.map { $0.siddetSeviyesi }.reduce(0, +) / Double(attacks.count)
        
        var triggerCounts: [String: Int] = [:]
        for attack in attacks {
            for trigger in attack.tetikleyiciFaktorler {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        
        let mostCommonTrigger = triggerCounts.max(by: { $0.value < $1.value })?.key ?? "Yok"
        
        return (totalAttacks, averageSeverity, mostCommonTrigger)
    }
}
