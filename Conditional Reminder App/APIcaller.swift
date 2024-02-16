//
//  APIcaller.swift
//  Conditional Reminder App
//
//  Created by Marlene on 05.02.24.
//

/*

import Foundation

// responsible for making the API calls

class OpenAIApiCaller {
    static let shared = OpenAIApiCaller()
    
    private let apiKey = "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"
    private let session = URLSession.shared
    private let baseUrl = "https://api.openai.com/v1"
    
    private init() {}
    
    func generateText(from prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/completions"
        guard let url = URL(string: baseUrl + endpoint) else {
            completion(.failure(NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "text-davinci-003", // Specify the model you want to use
            "prompt": prompt,
            "max_tokens": 100 // Adjust based on your needs
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "OpenAIError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network request failed"])))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let text = result.choices.first?.text {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "OpenAIError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No text found in response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

 */
