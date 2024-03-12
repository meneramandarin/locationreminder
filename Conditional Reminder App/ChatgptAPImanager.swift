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
  private let apiKey = "meow"

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
                    "content":"Please extract the following information from the provided instruction, focusing on the essence of the message and selecting the most relevant location. Provide the output in this format:\n\nMessage: (brief summary of the main task or reminder)\nWhen: (exact date or time reference from the transcription if available, otherwise YYYY-MM-DD format if date is known, or concise concepts like \"tomorrow\", \"tonight\", \"next week\")\nLocation: (most relevant location for the task, concisely stated without unnecessary words like \"close to\" or \"next to\")\n\nThe location should be the general area or context of the task, not a specific place like a restaurant or store, unless that is the only location mentioned. Focus on capturing the key information concisely, avoiding outputs such as \"Back home\", \"Later tonight\", \"Sometime next week\", \"Close to an IKEA\", or \"Next to a Trader Joe's\". Instead, use concise outputs like \"home\", \"tonight\", \"next week\", \"IKEA\", or \"Trader Joe's\".\n\nPlease process the following instructions:\n\n\(transcription)",
                        
                        // "Please extract the following information from the provided instruction, providing the output in a specific format: \n*text of user's instruction*\n* Message:\n* When:\n* Location: \(transcription)",
                        
                        // "Please extract the following information from the provided instruction, providing the output in a specific format: \n*text of user's instruction*\n* Message:\n* Date (format: YYYY-MM-DD):\n* Location Coordinates: \(transcription)",
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

                            print("Raw content line: \(content)")

                            for line in lines {
                                if line.starts(with: "Message:") {
                                    structuredMessage = String(line.dropFirst("Message:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                                    print("Extracted Message: \(structuredMessage ?? "nil")")
                                } else if line.starts(with: "When:") {
                                    let dateString = String(line.dropFirst("When:".count)).trimmingCharacters(in: .whitespacesAndNewlines)

                                    // Use ConceptOfTime to handle different date formats
                                    if let parsedDate = ConceptOfTime.shared.convertRelativeTime(dateString) {
                                        date = parsedDate
                                    } else if dateString.isEmpty {
                                        // If date is empty, default to today's date
                                        date = Date()
                                    } else {
                                        // Attempt to parse the date string using a common format
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "yyyy-MM-dd"
                                        date = formatter.date(from: dateString)
                                    }

                                    print("Extracted Date String: \(dateString)")
                                    print("Parsed Date: \(date != nil ? String(describing: date!) : "nil")")
                                } else if line.starts(with: "Location:") {
                                    let locationString = String(line.dropFirst("Location:".count)).trimmingCharacters(in: .whitespacesAndNewlines)

                                    // Check if the parsed location matches any of the user-defined hotspots
                                    if let reminderStorage = self.reminderStorage,
                                        let hotspot = reminderStorage.findHotspot(with: locationString) {
                                        location = hotspot.location
                                        print("Matched Hotspot: \(hotspot.name)")

                                        // Check if all components are successfully parsed and save the reminder
                                        if let structuredMessage = structuredMessage, let date = date {
                                            print("structuredMessage: \(structuredMessage)")
                                            print("date: \(date)")
                                            print("location: \(location)")

                                            guard let location = location else {
                                                completion(.failure(APIError.incompleteData))
                                                return
                                            }

                                            let newReminder = Reminder(
                                                id: UUID(), location: location, message: structuredMessage, date: date
                                            )

                                            if let reminderStorage = self.reminderStorage {
                                                reminderStorage.saveReminder(newReminder)
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
                                                completion(.failure(APIError.incompleteData))
                                            }
                                        }
                                    } else {
                                        // If the location is not a hotspot, use the searchLocation function
                                        LocationService.shared.searchLocation(query: locationString) { coordinate in
                                            if let coordinate = coordinate {
                                                location = coordinate
                                                print("Parsed Location: \(location)")

                                                // Check if all components are successfully parsed and save the reminder
                                                if let structuredMessage = structuredMessage, let date = date {
                                                    print("structuredMessage: \(structuredMessage)")
                                                    print("date: \(date)")
                                                    print("location: \(location)")

                                                    guard let location = location else {
                                                        completion(.failure(APIError.incompleteData))
                                                        return
                                                    }

                                                    let newReminder = Reminder(
                                                        id: UUID(), location: location, message: structuredMessage, date: date
                                                    )

                                                    if let reminderStorage = self.reminderStorage {
                                                        reminderStorage.saveReminder(newReminder)
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
                                                        completion(.failure(APIError.incompleteData))
                                                    }
                                                }
                                            } else {
                                                print("Error: Failed to retrieve location coordinates")
                                                completion(.failure(APIError.incompleteData))
                                            }
                                            
                                            // notification that reminder has been saved
                                            
                                            NotificationCenter.default.post(name: .reminderAdded, object: nil)

                                            
                                        }
                                    }
                                }
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

extension Notification.Name {
    static let reminderAdded = Notification.Name("ReminderAdded")
}
