//
//  AWSKeyStorage.swift
//  Conditional Reminder App
//
//  Created by Marlene on 14.03.24.
//

import Foundation
import CommonCrypto

class AWSKeyStorage {
    static let shared = AWSKeyStorage()
    private init() {}
    
    private let secretsManagerEndpoint = "https://secretsmanager.us-east-1.amazonaws.com"
    private let secretName = "meow"
    private let region = "us-east-1"
    private let accessKeyId = "meow"
    private let secretAccessKey = "meow"
    
    func retrieveAPIKey(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(secretsManagerEndpoint)/\(region)/secrets/\(secretName)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        request.addValue(getSignedHeaders(), forHTTPHeaderField: "Authorization")
        request.addValue(region, forHTTPHeaderField: "X-Amz-Target")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "AWSKeyStorage", code: -1, userInfo: ["message": "No data received"])))
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let secretString = jsonResult["SecretString"] as? String {
                    completion(.success(secretString))
                } else {
                    completion(.failure(NSError(domain: "AWSKeyStorage", code: -1, userInfo: ["message": "Invalid JSON response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func getSignedHeaders() -> String {
        let dateString = getCurrentDateString()
        let dateTimeString = getCurrentDateTimeString()
        
        let baseCanonicalRequest = """
        POST
        /\(region)/secrets/\(secretName)
        
        content-type:application/x-amz-json-1.1
        host:\(secretsManagerEndpoint.components(separatedBy: "://")[1])
        x-amz-date:\(dateTimeString)
        
        content-type;host;x-amz-date
        """
        
        let hashedCanonicalRequest = hexdigest(data: SHA256(string: baseCanonicalRequest))
        
        let canonicalRequest = """
        \(baseCanonicalRequest)
        \(hashedCanonicalRequest)
        """
        
        let stringToSign = """
        AWS4-HMAC-SHA256
        \(dateTimeString)
        \(dateString)/\(region)/secretsmanager/aws4_request
        \(hashedCanonicalRequest)
        """
        
        let signingKey = getSignatureKey(key: secretAccessKey, dateStamp: dateString, regionName: region, serviceName: "secretsmanager")
        let signature = hexdigest(data: hmac(string: stringToSign, key: signingKey))
        
        let authorizationHeader = "AWS4-HMAC-SHA256 Credential=\(accessKeyId)/\(dateString)/\(region)/secretsmanager/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=\(signature)"
        
        return authorizationHeader
    }

    // ... (keep the rest of the code unchanged)

    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: Date())
    }

    private func getCurrentDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: Date())
    }

    private func SHA256(string: String) -> Data {
        let data = string.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    private func hmac(string: String, key: Data) -> Data {
        let data = string.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { dataBuffer in
            key.withUnsafeBytes { keyBuffer in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBuffer.baseAddress, key.count, dataBuffer.baseAddress, data.count, &hash)
            }
        }
        return Data(hash)
    }

    private func getSignatureKey(key: String, dateStamp: String, regionName: String, serviceName: String) -> Data {
        let kSecret = "AWS4" + key
        let kDate = hmac(string: dateStamp, key: kSecret.data(using: .utf8)!)
        let kRegion = hmac(string: regionName, key: kDate)
        let kService = hmac(string: serviceName, key: kRegion)
        let kSigning = hmac(string: "aws4_request", key: kService)
        return kSigning
    }

    private func hexdigest(data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
