//
//  MessageBubble.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(15)
                    .background(
                        message.isUser ? AppColor.mainColor : Color.white
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: message.isUser ? 20 : 5,
                            bottomTrailingRadius: message.isUser ? 5 : 20,
                            topTrailingRadius: 20
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
            }
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
