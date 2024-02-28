//
//  APIManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 27.02.24.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()

    private let openAIURL = "https://api.openai.com/v1"
    private let apiKey = "meowmeowmeow"

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
            "model": "gpt-3.5-turbo",
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
