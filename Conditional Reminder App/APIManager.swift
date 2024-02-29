//
//  APIManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 27.02.24.
//

import Foundation

class APIManager {
    static let shared = APIManager()

    private let openAIURL = "https://api.openai.com/v1"
    private let apiKey = "meowmeowmeow"

    private init() {}

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
            httpBody.append(try Data(contentsOf: fileURL))
        } catch {
            completion(.failure(error))
            return
        }
        httpBody.append("\r\n".data(using: .utf8)!)

        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        httpBody.append("whisper-1".data(using: .utf8)!)
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("----- Transcription Response -----")
            print("Response: \(response)")

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error with HTTP Response")
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: ["message": "Missing data"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let transcriptionResponse = try decoder.decode(OpenAITranscriptionResponse.self, from: data)
                if let transcription = transcriptionResponse.text {
                    completion(.success(transcription))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: ["message": "Transcription missing"])))
                }
            } catch {
                completion(.failure(error)) // Or a specific error type if you can decode that
            }
        }
        task.resume()
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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error with HTTP Response")
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: -2, userInfo: ["message": "Response missing"])))
                return
            }

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
        }
        task.resume()
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



// USING ALAMOFIRE WHICH XCODE SEEMS TO HATE

/*
import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()

    private let openAIURL = "https://api.openai.com/v1"
    private let apiKey = "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"

    private init() {}

    func transcribeAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
        ]

        let url = "\(openAIURL)/audio/transcriptions"
        
        print("----- Transcribe Audio Debug -----") // Added for clarity
        print("API Key: \(apiKey)")
        print("File URL: \(fileURL)")
        print("Headers: \(headers)")

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "file")
            multipartFormData.append("whisper-1".data(using: .utf8)!, withName: "model")
        }, to: url, headers: headers)
        .responseDecodable(of: OpenAITranscriptionResponse.self) { response in  // Decode with custom struct
            print("----- Transcription Response -----") // For clarity
            print("Response: \(response)") // Print the full response
            
            switch response.result {
            case .success(let transcriptionResponse):
                if let transcription = transcriptionResponse.text {
                    completion(.success(transcription))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: ["message": "Transcription missing"])))
                }
            case .failure(let error):
                        print("Error transcribing audio: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }

    func chatAPI(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let url = "\(openAIURL)/chat/completions"
        let parameters: [String: Any] = [
            "model": "whisper-1",
            "messages": [["role": "user", "content": prompt]] // Array for message structure
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: OpenAIChatResponse.self) { response in // Decode with custom struct
                switch response.result {
                case .success(let chatResponse):
                    if let responseText = chatResponse.choices.first?.message.content {
                        completion(.success(responseText))
                    } else {
                        completion(.failure(NSError(domain: "OpenAI", code: -2, userInfo: ["message": "Response missing"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
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


*/
