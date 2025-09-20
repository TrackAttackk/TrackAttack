//
//  ChatBotView.swift
//  RiskTest
//
//  Created by selinay ceylan on 18.09.2025.
//

import SwiftUI

struct ChatBotView: View {
    @StateObject private var viewModel = ChatBotViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.98, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("Sağlık Asistanı")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.18, green: 0.22, blue: 0.28))
                    
                    Text("7/24 size yardımcı olmak için buradayım")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 15)
                .background(Color.white)
                
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    LoadingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            if viewModel.showingQuickReplies && viewModel.messages.count == 1 {
                                QuickRepliesView(replies: viewModel.quickReplies) { reply in
                                    viewModel.sendQuickReply(reply)
                                }
                                .padding(.top, 10)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    if !viewModel.showingQuickReplies && viewModel.messages.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.quickReplies, id: \.self) { reply in
                                    QuickReplyButton(text: reply) {
                                        viewModel.sendQuickReply(reply)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        TextField("Mesajınızı yazın...", text: $viewModel.messageText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .onSubmit {
                                viewModel.sendMessage()
                            }
                        
                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .background(AppColor.mainColor)
                        .clipShape(Circle())
                        .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .background(Color(red: 0.97, green: 0.98, blue: 0.98))
                
            }
        }
    }
}


#Preview {
    ChatBotView()
}
