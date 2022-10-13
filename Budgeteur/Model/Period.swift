//
//  Period.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 12/10/22.
//

import Foundation

/// Periods of time that are useful for reporting expenses/income.
enum Period: String, CaseIterable, Identifiable {
    /// ``id`` is used so that ``Period`` instances can be used in a `Picker` view seamlessly.
    var id: Self { self }
    
    case oneDay = "1D"
    case oneWeek = "1W"
    case twoWeeks = "2W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    
    
    /// Find the calendar quarter for a date, and return the start of the quarter.
    /// - Parameter date: A date.
    /// - Returns: The date of the first day of the calendar quarter that the given date belongs to.
    func getQuarterStart(for date: Date) throws -> Date {
        let calendar = Calendar.current
        // Months are one-indexed so we subtract one.
        let quarter = (calendar.component(.month, from: date) - 1) / 3
        let quarterStart = quarter * 3 + 1
        
        return calendar.date(from: DateComponents(
            year: calendar.component(.year, from: date),
            month: quarterStart
        ))!
    }
    
    /// Get the date interval for the user selected time period.
    /// - Parameter date: A date.
    /// - Returns: A date interval corresponding to the date and selected time period.
    func getDateInterval(for date: Date) -> DateInterval {
        // Use ISO8601 calendar to ensure weeks start from monday
        let calendar = Calendar(identifier: .iso8601)
        var startDate: Date
        var endDate: Date
        
        switch(self) {
        case .oneDay:
            startDate = date
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        case .oneWeek:
            startDate = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            )!
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        case .twoWeeks:
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            if day < 15 {
                startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
                endDate = calendar.date(from: DateComponents(year: year, month: month, day: 14))!
            } else {
                startDate = calendar.date(from: DateComponents(year: year, month: month, day: 15))!
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            }
        case .oneMonth:
            startDate = calendar.date(
                from: calendar.dateComponents([.year, .month], from: date)
            )!
            endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        case .threeMonths:
            startDate = try! getQuarterStart(for: date)
            endDate = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: startDate)!
        case .oneYear:
            startDate = calendar.date(
                from: calendar.dateComponents([.year], from: date)
            )!
            endDate = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startDate)!
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
}
