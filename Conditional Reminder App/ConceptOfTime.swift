//
//  ConceptOfTime.swift
//  Conditional Reminder App
//
//  Created by Marlene on 07.03.24.
//

import Foundation

class ConceptOfTime {
    static let shared = ConceptOfTime()
    
    private let dateFormatter: DateFormatter
    private let calendar: Calendar
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        
        calendar = Calendar.current
    }
    
    
    //  TODO: refine definitions 
    func convertRelativeTime(_ relativeTime: String) -> (Date?, Date?)? {
            let currentDate = Date()
            
            switch relativeTime.lowercased() {
            case "tomorrow":
                let startDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
                return (startDate, startDate)
            case "tonight":
                let startDate = calendar.startOfDay(for: currentDate)
                return (startDate, startDate)
            default:
                if let weekday = dateFormatter.date(from: relativeTime) {
                    let components = calendar.dateComponents([.weekday], from: weekday)
                    if let nextWeekday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                        return (nextWeekday, nextWeekday)
                    }
                }
                return nil
            }
        }
    
    func extractRelativeTime(from input: String) -> String? {
        let components = input.components(separatedBy: " ")
        if let lastWord = components.last {
            return lastWord
        }
        return nil
    }
    
    func getFormattedDate(from date: Date) -> String {
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        return formattedDate
    }
    
    func getFormattedDateRange(from startDate: Date, to endDate: Date) -> String {
            let startDateString = getFormattedDate(from: startDate)
            let endDateString = getFormattedDate(from: endDate)
            return "\(startDateString) - \(endDateString)"
        }
}
