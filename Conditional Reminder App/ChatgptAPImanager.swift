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
  var reminderStorage: ReminderStorage?  // to save reminder

  private let openAIURL = "https://api.openai.com/v1/chat/completions"
  private let apiKey = "meow meow meow"

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

      // Print Raw API Response (if successful)
      if let data = data {  // Ensure data exists
        print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "No data")")
      } else {
        print("Raw API Response: No data received")
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
          NSError(
            domain: "com.yourappdomain",
            code: (response as? HTTPURLResponse)?.statusCode ?? -1,
            userInfo: [
              "message":
                "Unexpected error (HTTP Status: \((response as? HTTPURLResponse)?.statusCode ?? -1))"
            ]
          )
        )
      )
      print("Raw API Response: \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")")  // Attempt to print as text
    }.resume()
  }

  struct StructuredChatResponse {
    let message: String?
    let date: Date?
    let location: CLLocationCoordinate2D?
  }

  struct ChatGPTResponse: Decodable {
    let choices: [Choice]
  }

  struct ChatCompletionResponse: Decodable {  // Matches the overall API response
    let choices: [Choice]  // Likely an array now
  }

  struct Choice: Decodable {
    let message: Message  // Nested structure
  }

  struct Message: Decodable {
    let role: String?
    let content: String?
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
        text: String, transcription: String,
        completion: @escaping (Result<StructuredChatResponse, Error>) -> Void
    ) {
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content":
                        "Please extract the following information from the provided instruction, providing the output in a specific format: \n*text of user's instruction*\n* Message:\n* Date:\n* Location Coordinates: \(transcription)",
                ]
            ],
            "temperature": 0.5,
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

        self.performRequest(with: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ChatGPTResponse.self, from: data)

                    if let firstChoice = response.choices.first {
                        let message = firstChoice.message

                        if message.role == "assistant",
                           let content = message.content {
                            let lines = content.split(separator: "\n")
                            var structuredMessage: String?
                            var date: Date?
                            var location: CLLocationCoordinate2D?
                            
                            print("Raw content line: \(content)") // See the exact input

                            for line in lines {
                                if line.starts(with: "* Message:") {
                                    structuredMessage = String(line.dropFirst("* Message:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                                    print("Extracted Message: \(structuredMessage ?? "nil")")
                                } else if line.starts(with: "* Date:") {
                                    let dateString = String(line.dropFirst("* Date:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                                    date = self.formatDate(from: dateString)
                                    print("Extracted Date String: \(dateString)")
                                    print("Parsed Date: \(date != nil ? String(describing: date!) : "nil")")
                                } else if line.starts(with: "* Location Coordinates:") {
                                    let coordinatesString = String(line.dropFirst("* Location Coordinates:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                                    location = self.parseCoordinates(from: coordinatesString)
                                    print("Extracted Coordinates String: \(coordinatesString)")
                                    print("Parsed Location: \(location != nil ? String(describing: location!) : "nil")")
                                }
                            }

                            // If all components are successfully parsed, save the reminder.
                            if let structuredMessage = structuredMessage, let date = date, let location = location {
                                print("structuredMessage: \(structuredMessage)")
                                print("date: \(date)")
                                print("location: \(location)")

                                let newReminder = Reminder(
                                    id: UUID(), location: location, message: structuredMessage, date: date
                                )

                                self.reminderStorage?.saveReminder(newReminder)
                                completion(
                                    .success(
                                        StructuredChatResponse(
                                            message: structuredMessage, date: date, location: location)))
                            } else {
                                if structuredMessage == nil {
                                    print("Error: Message not found in API response")
                                }
                                if date == nil {
                                    print("Error: Date not found or failed to parse")
                                }
                                if location == nil {
                                    print("Error: Location not found or failed to parse")
                                }
                                completion(.failure(APIError.incompleteData))
                            }
                        } else {
                            completion(.failure(APIError.invalidResponse))
                        }
                    } else {
                        print("Response did not contain any choices.")
                        completion(.failure(APIError.invalidResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


  enum APIError: Error {
    case invalidResponse
    case dateParsingError // For potential issues with the date
    case coordinateParsingError // For potential issues with location coordinates
    case incompleteData // For when required components are missing
  }
}
