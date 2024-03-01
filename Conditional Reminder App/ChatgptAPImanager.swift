//
//  ChatgptAPImanager.swift
//  Conditional Reminder App
//
//  Created by Marlene on 29.02.24.
//

// Chat GPT API

import CoreLocation
import Foundation

class GPTapiManager {
  static let shared = GPTapiManager()

  private let openAIURL = "https://api.openai.com/v1/completions"
  private let apiKey = "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"

  private init() {}

  // Configuration for retries and delays
  private let maxRetries = 3
  private let initialDelay = 1.0
  private let backoffFactor = 2.0

  // Helper function to handle retries
  private func performRequest(
    with urlRequest: URLRequest, currentRetry: Int = 0,
    completion: @escaping (Result<Data, Error>) -> Void
  ) {
    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 429 {
          if let retryAfterValue = httpResponse.value(forHTTPHeaderField: "Retry-After"),
            let retryAfterSeconds = Double(retryAfterValue)
          {
            DispatchQueue.main.asyncAfter(deadline: .now() + retryAfterSeconds) {
              self.performRequest(
                with: urlRequest, currentRetry: currentRetry + 1, completion: completion)
            }
            return
          } else {
            // Handle missing Retry-After... use exponential backoff
            let delay = self.initialDelay * pow(self.backoffFactor, Double(currentRetry))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
              self.performRequest(
                with: urlRequest, currentRetry: currentRetry + 1, completion: completion)
            }
            return
          }
        } else if (200...299).contains(httpResponse.statusCode) {
          completion(.success(data ?? Data()))  // Handle successful response
          return
        }
      }

      // Handle other non-success error codes or unexpected scenarios
      completion(
        .failure(
          NSError(domain: "com.yourappdomain", code: -1, userInfo: ["message": "Unexpected error"]))
      )
    }.resume()
  }

  struct StructuredChatResponse {
    let message: String?
    let date: Date?
    let location: CLLocationCoordinate2D?
  }

  func parseCoordinates(from coordinatesString: String) -> CLLocationCoordinate2D? {
    let components = coordinatesString.components(separatedBy: ",")
    guard components.count == 2,
      let latitude = Double(components[0].trimmingCharacters(in: .whitespaces)),
      let longitude = Double(components[1].trimmingCharacters(in: .whitespaces))
    else {
      return nil  // Invalid coordinates format
    }

    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  func formatDate(from dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    return dateFormatter.date(from: dateString)
  }

  func processInstruction(
    text: String, completion: @escaping (Result<StructuredChatResponse, Error>) -> Void
  ) {
    let requestBody: [String: Any] = [
      "model": "text-davinci-003",
      "prompt": text,  // prompt goes here
      "temperature": 0.5,  // Adjust as desired
      "max_tokens": 100,
      "top_p": 1.0,
      "frequency_penalty": 0.0,
      "presence_penalty": 0.0,
    ]

    guard let url = URL(string: "\(openAIURL)") else {
      completion(
        .failure(
          NSError(domain: "com.yourappdomain", code: -1, userInfo: ["message": "Invalid URL"])))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.performRequest(with: request) { result in
      switch result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          let response = try decoder.decode(ChatGPTResponse.self, from: data)

          if let choice = response.choices.first {
            let lines = choice.text.split(separator: "\n")
            var address: String?
            var task: String?
            var date: String?
            var location: CLLocationCoordinate2D?

            for line in lines {
              if line.starts(with: "Address: ") {
                address = line.replacingOccurrences(of: "Address: ", with: "").trimmingCharacters(
                  in: .whitespacesAndNewlines)
              } else if line.starts(with: "Task: ") {
                task = line.replacingOccurrences(of: "Task: ", with: "").trimmingCharacters(
                  in: .whitespacesAndNewlines)
                  if line.starts(with: "Date: ") {
                      let dateString = line.replacingOccurrences(of: "Date: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                      if let date = formatDate(from: dateString) {
                          var date: Date?
                      } else {
                          // Handle the potential error if the date is not in the correct format
                      }
                  }
              } else if line.starts(with: "Location Coordinates: ") {
                  let coordinatesString = line.replacingOccurrences(of: "Location Coordinates: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                  location = parseCoordinates(from: String(coordinatesString)) // Convert to String
              }
            }

            completion(
              .success(
                StructuredChatResponse(address: address, task: task, date: date, location: location)
              ))
          } else {
            completion(.failure(error))
          }
        }
      }
    }

    struct ChatGPTResponse: Decodable {  // Matches the overall API response
      let choices: [Choice]
    }

    struct Choice: Decodable {
      let text: String
    }

  }
}