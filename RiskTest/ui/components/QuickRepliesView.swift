//
//  QuickRepliesView.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import SwiftUI

struct QuickRepliesView: View {
    let replies: [String]
    let onReplyTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hızlı Seçenekler")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                ForEach(replies, id: \.self) { reply in
                    QuickReplyButton(text: reply) {
                        onReplyTap(reply)
                    }
                }
            }
        }
    }
}
