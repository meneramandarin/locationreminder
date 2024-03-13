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
    

    func convertRelativeTime(_ relativeTime: String) -> (Date?, Date?)? {
            let currentDate = Date()
            
            switch relativeTime.lowercased() {
            
            case "tomorrow":
                let startDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
                return (startDate, startDate)
           
            case "tonight":
                let startDate = calendar.startOfDay(for: currentDate)
                return (startDate, startDate)
           
            case "next year":
                    let startDate = calendar.date(byAdding: .year, value: 1, to: calendar.startOfDay(for: currentDate))
                    let endDate = calendar.date(byAdding: .year, value: 1, to: calendar.startOfDay(for: currentDate))
                    return (startDate, endDate)
                    
                default:
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US")
                    
                    // Check for month names
                    dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
                    if let date = dateFormatter.date(from: relativeTime) {
                        let components = calendar.dateComponents([.month, .year], from: currentDate)
                        let startOfMonth = calendar.date(from: DateComponents(year: components.year, month: calendar.component(.month, from: date), day: 1))
                        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth!)
                        return (startOfMonth, endOfMonth)
                    }
                    
                    // Check for abbreviated month names
                    dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
                    if let date = dateFormatter.date(from: relativeTime) {
                        let components = calendar.dateComponents([.month, .year], from: currentDate)
                        let startOfMonth = calendar.date(from: DateComponents(year: components.year, month: calendar.component(.month, from: date), day: 1))
                        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth!)
                        return (startOfMonth, endOfMonth)
                    }
                    
                    // Check for weekday names
                    dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
                    if let date = dateFormatter.date(from: relativeTime) {
                        let components = calendar.dateComponents([.weekday], from: date)
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
