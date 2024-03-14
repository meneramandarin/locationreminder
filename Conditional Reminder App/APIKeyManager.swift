//
//  APIKeyManager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 14.03.24.
//

import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    private init() {}
    
    private var apiKey: String?
    
    func initialize() {
        // Retrieve the API key from TemporaryKeyStorage or a secure server
        let key = TemporaryKeyStorage.apiKey
        
        // Save the API key to the Keychain
        let data = key.data(using: .utf8)
        let status = KeychainHelper.standard.save(data!, service: "YourAppName", account: "APIKey")
        
        if status == errSecSuccess {
            print("API key saved to Keychain successfully")
            apiKey = key
        } else {
            print("Failed to save API key to Keychain")
        }
    }
    
    func getAPIKey() -> String? {
        if let key = apiKey {
            return key
        } else {
            // Retrieve the API key from the Keychain
            if let data = KeychainHelper.standard.read(service: "OpenAI Keys for Memo", account: "APIKey"),
               let key = String(data: data, encoding: .utf8) {
                apiKey = key
                return key
            } else {
                print("API key not found in Keychain")
                return nil
            }
        }
    }
}
