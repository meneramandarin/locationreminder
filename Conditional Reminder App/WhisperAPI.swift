//
//  WhisperAPI.swift
//  Conditional Reminder App
//
//  Created by Marlene on 26.02.24.
//

import Foundation

class WhisperAPIService {
    private let apiKey = "meowmeoemeow"
    private let uploadURL = URL(string: "https://api.openai.com/v1/audio/speech")!

    func transcribeAudio(completion: @escaping (Result<String, Error>) -> Void) {
        // Use the same document directory path and file name as VoiceInputManager
        let audioFilePath = VoiceInputManager.shared.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        // Prepare the request
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare the multipart/form-data body
        let httpBody = NSMutableData()
        if let audioData = try? Data(contentsOf: audioFilePath) {
            httpBody.append(convertFileData(fieldName: "file",
                                            fileName: audioFilePath.lastPathComponent,
                                            mimeType: "audio/m4a",
                                            fileData: audioData,
                                            using: boundary))
        }
        
        httpBody.appendString("--\(boundary)--")
        
        request.httpBody = httpBody as Data
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                            completion(.failure(NSError(domain: "WhisperError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                            return
                        }
            
            do {
                            // Assuming the JSON structure has a "transcription" field
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let transcription = json["transcription"] as? String {
                                print("Transcribed Text: \(transcription)") // Print the transcription
                                completion(.success(transcription))
                            } else {
                                completion(.failure(NSError(domain: "WhisperError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse transcription"])))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }.resume()
    }
    
    private func convertFileData(fieldName: String,
                                 fileName: String,
                                 mimeType: String,
                                 fileData: Data,
                                 using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        return data as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
