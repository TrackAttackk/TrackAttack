//
//  NotificationManager.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Bildirim izni verildi")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func sendRiskIncreaseNotification(from oldRisk: String, to newRisk: String) {
        let riskLevels = ["Düşük Risk": 0, "Orta Risk": 1, "Yüksek Risk": 2]
        
        guard let oldLevel = riskLevels[oldRisk],
              let newLevel = riskLevels[newRisk],
              newLevel > oldLevel else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Kalp Sağlığı Uyarısı"
        
        switch newRisk {
        case "Orta Risk":
            content.body = "Risk seviyeniz Orta Risk'e yükseldi. Lütfen daha dikkatli olun ve gerekirse doktorunuza danışın."
            content.sound = .default
            
        case "Yüksek Risk":
            content.body = "Risk seviyeniz Yüksek Risk'e yükseldi! Acil olarak bir sağlık uzmanına danışmanız önerilir."
            content.sound = .defaultCritical
            
        default:
            return
        }
        
        content.badge = 1
        content.categoryIdentifier = "HEART_RISK_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "risk_increase_\(Date().timeIntervalSince1970)",
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim gönderilemedi: \(error.localizedDescription)")
            } else {
                print("Risk artışı bildirimi gönderildi: \(oldRisk) -> \(newRisk)")
            }
        }
    }
    
    func scheduleHealthCheckReminder() {
        let content = UNMutableNotificationContent()
        content.title = "💓 Günlük Sağlık Kontrolü"
        content.body = "Bugünkü kalp sağlığınızı kontrol etmeyi unutmayın!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_health_check",
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Günlük hatırlatma ayarlanamadı: \(error.localizedDescription)")
            } else {
                print("Günlük hatırlatma ayarlandı")
            }
        }
    }
    
    func sendCriticalHeartRateAlert(heartRate: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Kritik Kalp Atışı"
        content.body = "Kalp atış hızınız \(heartRate) bpm. Bu anormal bir değer olabilir, lütfen dikkat edin."
        content.sound = .defaultCritical
        content.badge = 1
        content.categoryIdentifier = "CRITICAL_HEART_RATE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "critical_heart_rate_\(Date().timeIntervalSince1970)",
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Kritik nabız bildirimi gönderilemedi: \(error.localizedDescription)")
            } else {
                print("Kritik nabız bildirimi gönderildi: \(heartRate) bpm")
            }
        }
    }
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension NotificationManager {
    func setupNotificationActions() {
        let doctorAction = UNNotificationAction(identifier: "DOCTOR_ACTION",
                                              title: "Doktora Git",
                                              options: [.foreground])
        
        let remindLaterAction = UNNotificationAction(identifier: "REMIND_LATER",
                                                   title: "Daha Sonra Hatırlat",
                                                   options: [])
        
        let riskCategory = UNNotificationCategory(identifier: "HEART_RISK_ALERT",
                                                actions: [doctorAction, remindLaterAction],
                                                intentIdentifiers: [],
                                                options: [])
        
        let criticalCategory = UNNotificationCategory(identifier: "CRITICAL_HEART_RATE",
                                                    actions: [doctorAction],
                                                    intentIdentifiers: [],
                                                    options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([riskCategory, criticalCategory])
    }
}
