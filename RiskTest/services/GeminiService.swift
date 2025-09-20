//
//  GeminiService.swift
//  RiskTest
//
//  Created by selinay ceylan on 20.09.2025.
//

import Foundation

class GeminiService: ObservableObject {
    private let apiKey = "AIzaSyDL6tvakUMqNgEkD3RCk_j_L9A4SjCw7HM"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    func sendMessage(_ message: String) async -> String {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY" else {
            return "API anahtarı eksik."
        }
        
        let prompt = """
        Sen bir sağlık asistanısın... 
        Kullanıcı mesajı: \(message)
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        do {
            guard let url = URL(string: baseURL) else { return "API URL hatası" }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                return "API hatası: \(httpResponse.statusCode)"
            }
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let candidates = jsonResponse?["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return "Yanıt alınamadı"
        } catch {
            return "Bağlantı hatası: \(error.localizedDescription)"
        }
    }
}
