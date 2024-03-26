//
//  ConceptOfTime.swift
//  Conditional Reminder App
//
//  Created by Marlene on 07.03.24.
//

// TODO: Implement short-circuit evaluation or early termination conditions to stop the parsing process as soon as a match is found, rather than continuing to iterate through the remaining concepts unnecessarily.

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
        let calendar = Calendar.current
        
        switch relativeTime.lowercased() {
        case "today":
            return (currentDate, currentDate)
            
        case "tomorrow":
            let startDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
            return (startDate, startDate)
            
        case "tonight":
            let startDate = calendar.startOfDay(for: currentDate)
            return (startDate, startDate)
            
        case "next year":
            let startDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentDate) + 1, month: 1, day: 1))
            let endDate = calendar.date(byAdding: .day, value: 7, to: startDate!)
            return (startDate, endDate)
            
        case "in a year", "in one year", "one year", "a year":
            let futureDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
            return (futureDate, futureDate)
            
        case "next month":
            let currentYear = calendar.component(.year, from: currentDate)
            let currentMonth = calendar.component(.month, from: currentDate)
            let nextMonth = currentMonth == 12 ? 1 : currentMonth + 1
            let nextYear = currentMonth == 12 ? currentYear + 1 : currentYear
            let startOfNextMonth = calendar.date(from: DateComponents(year: nextYear, month: nextMonth, day: 1))
            let endOfNextMonth = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: startOfNextMonth!)!)
            return (startOfNextMonth, endOfNextMonth)
            
        case "in a month", "in one month", "a month", "one month":
            let futureDate = calendar.date(byAdding: .day, value: 30, to: currentDate)
            return (futureDate, futureDate)
            
        case "next week":
            let currentWeekday = calendar.component(.weekday, from: currentDate)
            let daysToNextMonday = (9 - currentWeekday) % 7
            let startOfNextWeek = calendar.date(byAdding: .day, value: daysToNextMonday, to: calendar.startOfDay(for: currentDate))
            let endOfNextWeek = calendar.date(byAdding: .day, value: 6, to: startOfNextWeek!)
            return (startOfNextWeek, endOfNextWeek)
            
        case "this weekend", "next weekend":
            let currentWeekday = calendar.component(.weekday, from: currentDate)
            let isThursdayOrLater = currentWeekday >= 5 // Thursday is weekday 5
            
            var startDate: Date?
            var endDate: Date?
            
            if relativeTime.lowercased() == "this weekend" || (relativeTime.lowercased() == "next weekend" && !isThursdayOrLater) {
                // If it's "this weekend" or "next weekend" on Monday, Tuesday, or Wednesday
                let components = DateComponents(weekday: 7) // Saturday is weekday 7
                startDate = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime)
                endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
            } else if relativeTime.lowercased() == "next weekend" && isThursdayOrLater {
                // If it's "next weekend" on Thursday, Friday, Saturday, or Sunday
                let components = DateComponents(weekday: 7) // Saturday is weekday 7
                startDate = calendar.nextDate(after: calendar.date(byAdding: .day, value: 7, to: currentDate)!, matching: components, matchingPolicy: .nextTime)
                endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
            }
            
            return (startDate, endDate)
            
        case "in a week", "in one week", "one week", "a week":
            let futureDate = calendar.date(byAdding: .day, value: 7, to: currentDate)
            return (futureDate, futureDate)
            
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            
            // Check for month names
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            if let date = dateFormatter.date(from: relativeTime) {
                let components = calendar.dateComponents([.month, .year], from: currentDate)
                let startOfMonth = calendar.date(from: DateComponents(year: components.year, month: calendar.component(.month, from: date), day: 1))
                let endOfMonth = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: startOfMonth!)!)
                return (startOfMonth, endOfMonth)
            }
            
            // Check for abbreviated month names
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            if let date = dateFormatter.date(from: relativeTime) {
                let components = calendar.dateComponents([.month, .year], from: currentDate)
                let startOfMonth = calendar.date(from: DateComponents(year: components.year, month: calendar.component(.month, from: date), day: 1))
                let endOfMonth = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: startOfMonth!)!)
                return (startOfMonth, endOfMonth)
            }
            
            // Check for specific weekday names with "next"
            switch relativeTime.lowercased() {
            case "next monday":
                let components = DateComponents(weekday: 2)
                if let nextMonday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextMonday, nextMonday)
                }
            case "next tuesday":
                let components = DateComponents(weekday: 3)
                if let nextTuesday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextTuesday, nextTuesday)
                }
            case "next wednesday":
                let components = DateComponents(weekday: 4)
                if let nextWednesday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextWednesday, nextWednesday)
                }
            case "next thursday":
                let components = DateComponents(weekday: 5)
                if let nextThursday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextThursday, nextThursday)
                }
            case "next friday":
                let components = DateComponents(weekday: 6)
                if let nextFriday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextFriday, nextFriday)
                }
            case "next saturday":
                let components = DateComponents(weekday: 7)
                if let nextSaturday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextSaturday, nextSaturday)
                }
            case "next sunday":
                let components = DateComponents(weekday: 1)
                if let nextSunday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextSunday, nextSunday)
                }
            default:
                break
            }

            // Check for specific weekday names with "next week"
            switch relativeTime.lowercased() {
            case "next week monday":
                let components = DateComponents(weekday: 2)
                if let nextMonday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextMonday, nextMonday)
                }
            case "next week tuesday":
                let components = DateComponents(weekday: 3)
                if let nextTuesday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextTuesday, nextTuesday)
                }
            case "next week wednesday":
                let components = DateComponents(weekday: 4)
                if let nextWednesday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextWednesday, nextWednesday)
                }
            case "next week thursday":
                let components = DateComponents(weekday: 5)
                if let nextThursday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextThursday, nextThursday)
                }
            case "next week friday":
                let components = DateComponents(weekday: 6)
                if let nextFriday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextFriday, nextFriday)
                }
            case "next week saturday":
                let components = DateComponents(weekday: 7)
                if let nextSaturday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextSaturday, nextSaturday)
                }
            case "next week sunday":
                let components = DateComponents(weekday: 1)
                if let nextSunday = calendar.nextDate(after: calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!, matching: components, matchingPolicy: .nextTime) {
                    return (nextSunday, nextSunday)
                }
            default:
                break
            }
            
            // Check for weekday names without "next"
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
            if let date = dateFormatter.date(from: relativeTime) {
                let components = calendar.dateComponents([.weekday], from: date)
                if let nextWeekday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextWeekday, nextWeekday)
                }
            }
            
            // Check for weekday names without "next"
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
            if let date = dateFormatter.date(from: relativeTime) {
                let components = calendar.dateComponents([.weekday], from: date)
                if let nextWeekday = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime) {
                    return (nextWeekday, nextWeekday)
                }
            }
            
            // Check for "in x days"
            if relativeTime.lowercased().hasPrefix("in ") && relativeTime.lowercased().hasSuffix(" days") {
                if let daysString = relativeTime.lowercased().components(separatedBy: " ").dropFirst().dropLast().first,
                   let days = Int(daysString) {
                    let futureDate = calendar.date(byAdding: .day, value: days, to: currentDate)
                    return (futureDate, futureDate)
                }
            }
            
            // Check for "in x days" - hardcoded numbers
            if relativeTime.lowercased().hasPrefix("in ") && relativeTime.lowercased().hasSuffix(" days") {
                if let daysString = relativeTime.lowercased().components(separatedBy: " ").dropFirst().dropLast().first {
                    let numberWords = [
                        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
                        "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
                        "eleven": 11, "twelve": 12, "fourteen": 14, "hundred": 100
                    ]

                    if let days = numberWords[daysString] {
                        let futureDate = calendar.date(byAdding: .day, value: days, to: currentDate)
                        return (futureDate, futureDate)
                    }
                }
            }
            
            // Check for "in a couple of days"
            if relativeTime.lowercased() == "in a couple of days" {
                let startDate = calendar.date(byAdding: .day, value: 2, to: currentDate)
                let endDate = calendar.date(byAdding: .day, value: 2, to: startDate!)
                return (startDate, endDate)
            }

            // Check for "in x months"
            if relativeTime.lowercased().hasPrefix("in ") && relativeTime.lowercased().hasSuffix(" months") {
                if let monthsString = relativeTime.lowercased().components(separatedBy: " ").dropFirst().dropLast().first,
                   let months = Int(monthsString) {
                    let futureDate = calendar.date(byAdding: .month, value: months, to: currentDate)
                    return (futureDate, futureDate)
                }
            }

            // Check for "in a couple of months"
            if relativeTime.lowercased() == "in a couple of months" {
                let startDate = calendar.date(byAdding: .month, value: 2, to: currentDate)
                let endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)?.addingTimeInterval(-1)
                return (startDate, endDate)
            }

            // Check for "in x weeks"
            if relativeTime.lowercased().hasPrefix("in ") && relativeTime.lowercased().hasSuffix(" weeks") {
                if let weeksString = relativeTime.lowercased().components(separatedBy: " ").dropFirst().dropLast().first,
                   let weeks = Int(weeksString) {
                    let futureDate = calendar.date(byAdding: .day, value: weeks * 7, to: currentDate)
                    return (futureDate, futureDate)
                }
            }

            // Check for "in a couple of weeks"
            if relativeTime.lowercased() == "in a couple of weeks" {
                let startDate = calendar.date(byAdding: .day, value: 14, to: currentDate)
                let endDate = calendar.date(byAdding: .day, value: 6, to: startDate!)
                return (startDate, endDate)
            }

            // Check for "in x years"
            if relativeTime.lowercased().hasPrefix("in ") && relativeTime.lowercased().hasSuffix(" years") {
                if let yearsString = relativeTime.lowercased().components(separatedBy: " ").dropFirst().dropLast().first,
                   let years = Int(yearsString) {
                    let futureDate = calendar.date(byAdding: .year, value: years, to: currentDate)
                    return (futureDate, futureDate)
                }
            }

            // Check for "in a couple of years"
            if relativeTime.lowercased() == "in a couple of years" {
                let startDate = calendar.date(byAdding: .year, value: 2, to: currentDate)
                let endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)?.addingTimeInterval(-1)
                return (startDate, endDate)
            }
                
                // Check for "spring"
                        if relativeTime.lowercased() == "in spring" || relativeTime.lowercased() == "next spring" {
                            let (startDate, endDate) = getNextSeasonDates(for: "in spring", from: currentDate)
                            return (startDate, endDate)
                        }
                        
                        // Check for "summer"
                        if relativeTime.lowercased() == "in summer" || relativeTime.lowercased() == "next summer" {
                            let (startDate, endDate) = getNextSeasonDates(for: "in summer", from: currentDate)
                            return (startDate, endDate)
                        }
                        
                // Check for "autumn" or "fall"
                if relativeTime.lowercased() == "in autumn" || relativeTime.lowercased() == "in fall" ||
                   relativeTime.lowercased() == "next autumn" || relativeTime.lowercased() == "next fall" {
                    let (startDate, endDate) = getNextSeasonDates(for: "autumn", from: currentDate)
                    return (startDate, endDate)
                }
                        
                        // Check for "winter"
                        if relativeTime.lowercased() == "in winter" || relativeTime.lowercased() == "next winter" {
                            let (startDate, endDate) = getNextSeasonDates(for: "in winter", from: currentDate)
                            return (startDate, endDate)
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
    
    private func getNextSeasonDates(for season: String, from currentDate: Date) -> (Date, Date) {
            let currentYear = calendar.component(.year, from: currentDate)
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentDay = calendar.component(.day, from: currentDate)
            
            var startDate: Date
            var endDate: Date
            
            switch season.lowercased() {
            case "in spring":
                if currentMonth >= 3 && currentDay >= 20 {
                    startDate = DateComponents(calendar: calendar, year: currentYear + 1, month: 3, day: 20).date!
                } else {
                    startDate = DateComponents(calendar: calendar, year: currentYear, month: 3, day: 20).date!
                }
                endDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: startDate), month: 6, day: 19).date!
            case "in summer":
                if currentMonth >= 6 && currentDay >= 20 {
                    startDate = DateComponents(calendar: calendar, year: currentYear + 1, month: 6, day: 20).date!
                } else {
                    startDate = DateComponents(calendar: calendar, year: currentYear, month: 6, day: 20).date!
                }
                endDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: startDate), month: 9, day: 21).date!
            case "in autumn":
                if currentMonth >= 9 && currentDay >= 22 {
                    startDate = DateComponents(calendar: calendar, year: currentYear + 1, month: 9, day: 22).date!
                } else {
                    startDate = DateComponents(calendar: calendar, year: currentYear, month: 9, day: 22).date!
                }
                endDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: startDate), month: 12, day: 20).date!
            case "in winter":
                if currentMonth == 12 && currentDay >= 21 {
                    startDate = DateComponents(calendar: calendar, year: currentYear + 1, month: 12, day: 21).date!
                } else {
                    startDate = DateComponents(calendar: calendar, year: currentYear, month: 12, day: 21).date!
                }
                endDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: startDate) + 1, month: 3, day: 19).date!
            default:
                fatalError("Invalid season")
            }
            
            return (startDate, endDate)
        }
    
}
