//
//  APIManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 27.02.24.
//

// Whisper API

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private let openAIURL = "https://api.openai.com/v1" // "https://eofusffqsjbr92r.m.pipedream.net"
    private let apiKey = ""
    
    private init() {}
    
    // Configuration for retries and delays
    private let maxRetries = 3
    private let initialDelay = 1.0
    private let backoffFactor = 2.0
        
    // Helper function to handle retries
    private func performRequest(with urlRequest: URLRequest, currentRetry: Int = 0, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 429 {
                    if let retryAfterValue = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                       let retryAfterSeconds = Double(retryAfterValue) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryAfterSeconds) {
                            self.performRequest(with: urlRequest, currentRetry: currentRetry + 1, completion: completion)
                        }
                        return
                    } else {
                        // Handle missing Retry-After... use exponential backoff
                        let delay = self.initialDelay * pow(self.backoffFactor, Double(currentRetry))
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.performRequest(with: urlRequest, currentRetry: currentRetry + 1, completion: completion)
                        }
                        return
                    }
                } else if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(data ?? Data())) // Handle successful response
                    return
                }
            }
            
            // Handle other non-success error codes or unexpected scenarios
            completion(.failure(NSError(domain: "com.yourappdomain", code: -1, userInfo: ["message": "Unexpected error"])))
        }.resume()
    }
        
    func transcribeAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: [String: String] = [
            "Authorization": "Bearer \(apiKey)"
        ]
        
        guard let url = URL(string: "\(openAIURL)/audio/transcriptions") else {
            completion(.failure(NSError(domain: "com.yourappdomain", code: -1, userInfo: ["message": "Invalid URL"])))
            return
        }
        
        print("----- Transcribe Audio Debug -----")
        print("API Key: \(apiKey)")
        print("File URL: \(fileURL)")
        print("Headers: \(headers)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var httpBody = Data()
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        
        do {
          let fileData = try Data(contentsOf: fileURL) // Load entire file data
          httpBody.append(fileData) // Append in one step
        } catch {
          completion(.failure(error)) // Pass the error to your completion handler
          return // Exit the function if file loading fails
        }
        
        httpBody.append("\r\n".data(using: .utf8)!)
        
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        httpBody.append("whisper-1".data(using: .utf8)!)
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("httpBody:", httpBody)
        request.httpBody = httpBody
        
        print("Content-Length:", request.value(forHTTPHeaderField: "Content-Length"))
        
        self.performRequest(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let transcriptionResponse = try decoder.decode(OpenAITranscriptionResponse.self, from: data)
                    if let transcription = transcriptionResponse.text {
                        completion(.success(transcription))
                    } else {
                        completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: ["message": "Transcription missing"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func chatAPI(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: [String: String] = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        guard let url = URL(string: "\(openAIURL)/chat/completions") else {
            completion(.failure(NSError(domain: "com.yourappdomain", code: -2, userInfo: ["message": "Invalid URL"])))
            return
        }
        
        let parameters: [String: Any] = [
            "model": "whisper-1",
            "messages": [["role": "user", "content": prompt]]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        self.performRequest(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let chatResponse = try decoder.decode(OpenAIChatResponse.self, from: data)
                    if let responseText = chatResponse.choices.first?.message.content {
                        completion(.success(responseText))
                    } else {
                        completion(.failure(NSError(domain: "OpenAI", code: -2, userInfo: ["message": "Response text missing"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // match the potential error format returned by the OpenAI API.
    struct OpenAIErrorResponse: Decodable {
        let error: OpenAIErrorDetail
        
        struct OpenAIErrorDetail: Decodable {
            let message: String
            // Add other error fields that OpenAI might provide, if any
        }
    }
    
    // Consider creating these for better structure:
    struct OpenAITranscriptionResponse: Decodable {
        let text: String?
    }
    
    struct OpenAIChatResponse: Decodable {
        let choices: [Choice]
        
        struct Choice: Decodable {
            let message: Message
            
            struct Message: Decodable {
                let content: String
            }
        }
    }
}
