//
//  RiskTestApp.swift
//  RiskTest
//
//  Created by selinay ceylan on 16.09.2025.
//

import SwiftUI
import FirebaseCore
import UserNotifications

// AppDelegate sınıfı oluştur
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Bildirim center delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // Notification actions'ları ayarla
        NotificationManager.shared.setupNotificationActions()
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Uygulama açıkken bildirim geldiğinde
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Uygulama açıkken de bildirimi göster
        completionHandler([.alert, .badge, .sound])
    }
    
    // Bildirime tıklanma işlemleri
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "DOCTOR_ACTION":
            // Doktora git butonuna tıklandı
            print("Kullanıcı doktora gitmeyi seçti")
            
        case "REMIND_LATER":
            // Daha sonra hatırlat butonuna tıklandı
            scheduleReminderNotification()
            
        case UNNotificationDefaultActionIdentifier:
            // Normal tıklama - uygulamayı aç
            print("Bildirime tıklandı, uygulama açılıyor")
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // 30 dakika sonra hatırlat bildirimi
    private func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Kalp Sağlığı Hatırlatması"
        content.body = "Sağlık durumunuzla ilgili bir uzmanla görüşmeyi unutmayın."
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 dakika
        let request = UNNotificationRequest(identifier: "reminder_notification",
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Hatırlatma bildirimi ayarlanamadı: \(error.localizedDescription)")
            }
        }
    }
}

@main
struct RiskTestApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    
    // AppDelegate'i ekle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                if authViewModel.isNewUser {
                    OnBoardingView()
                        .environmentObject(authViewModel)
                        .navigationBarBackButtonHidden(true)
                } else {
                    HomeView(authViewModel: authViewModel)
                        .environmentObject(authViewModel)
                }
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
