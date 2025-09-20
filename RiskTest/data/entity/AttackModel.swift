//
//  AttackModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import FirebaseFirestore

struct AttackModel: Identifiable, Codable {
    let id = UUID()
    let documentId: String
    let tarihSaat: String
    let sure: Int
    let siddetSeviyesi: Double
    let tetikleyiciFaktorler: [String]
    let ekNotlar: String
    let email: String
    let timestamp: Date
    
    // Computed properties for UI
    var severityText: String {
        switch siddetSeviyesi {
        case 0.0..<0.25:
            return "Hafif"
        case 0.25..<0.5:
            return "Orta"
        case 0.5..<0.75:
            return "Şiddetli"
        default:
            return "Kritik"
        }
    }
    
    var severityType: String {
        switch siddetSeviyesi {
        case 0.0..<0.25:
            return "mild"
        case 0.25..<0.5:
            return "moderate"
        case 0.5..<0.75:
            return "severe"
        default:
            return "critical"
        }
    }
    
    var severityLevel: String {
        "\(Int(siddetSeviyesi * 10))/10"
    }
    
    var durationText: String {
        if sure < 60 {
            return "\(sure) dakika"
        } else {
            let hours = sure / 60
            let minutes = sure % 60
            if minutes == 0 {
                return "\(hours) saat"
            } else {
                return "\(hours) saat \(minutes) dakika"
            }
        }
    }
    
    var triggersText: String {
        tetikleyiciFaktorler.joined(separator: ", ")
    }
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.tarihSaat = data["tarihSaat"] as? String ?? ""
        self.sure = data["sure"] as? Int ?? 0
        self.siddetSeviyesi = data["siddetSeviyesi"] as? Double ?? 0.0
        self.tetikleyiciFaktorler = data["tetikleyiciFaktorler"] as? [String] ?? []
        self.ekNotlar = data["ekNotlar"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        
        if let firestoreTimestamp = data["createdAt"] as? Timestamp {
            self.timestamp = firestoreTimestamp.dateValue()
        } else {
            let formatter = DateFormatter()
            let formats = [
                "dd.MM.yyyy HH:mm",
                "dd.MM.yyyy H:mm",
                "d.MM.yyyy HH:mm",
                "d.M.yyyy HH:mm",
                "dd/MM/yyyy HH:mm",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            ]
            
            var parsedDate: Date?
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: tarihSaat) {
                    parsedDate = date
                    break
                }
            }
            self.timestamp = parsedDate ?? Date()
        }
    }
}
