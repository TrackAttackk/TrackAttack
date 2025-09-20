//
//  ChatBotViewModel.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation
import SwiftUI

@MainActor
class ChatBotViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages: [ChatMessage] = []
    @Published var showingQuickReplies = true
    @Published var isLoading = false
    
    private let geminiService = GeminiService()
    
    let quickReplies = [
        "Atak geçirdiğimde ne yapmalıyım?",
        "Tetikleyici faktörler neler?",
        "Nefes egzersizi öner",
        "Acil durum planım",
        "İlaç hatırlatıcısı"
    ]
    
    init() {
        messages = [
            ChatMessage(
                text: "Merhaba! Ben sizin sağlık asistanınızım. Kalp çarpıntısı, atak kayıtları ve sağlıklı yaşam konularında size yardımcı olabilirim. Nasıl yardımcı olabilirim?",
                isUser: false,
                timestamp: Date()
            )
        ]
    }
    
    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(
            text: trimmed,
            isUser: true,
            timestamp: Date()
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(userMessage)
            showingQuickReplies = false
        }
        
        messageText = ""
        isLoading = true
        
        Task {
            let response = await geminiService.sendMessage(trimmed)
            
            await MainActor.run {
                isLoading = false
                
                let botMessage = ChatMessage(
                    text: response,
                    isUser: false,
                    timestamp: Date()
                )
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    messages.append(botMessage)
                }
            }
        }
    }
    
    func sendQuickReply(_ text: String) {
        messageText = text
        sendMessage()
    }
}
