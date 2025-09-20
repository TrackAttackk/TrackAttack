//
//  ChatMessage.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}
