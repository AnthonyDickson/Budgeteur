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
        let date = calendar.startOfDay(for: date)
        
        switch(self) {
        case .oneDay:
            startDate = date
            endDate = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startDate)!
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
        
        return DateInterval(start: startDate, end: Calendar.current.endOfDay(for: endDate))
    }
    
    /// Get the date increment needed such that adding the increment to another date will create a date interval corresponding to the chosen time period.
    ///  For example given ``oneWeek``,  the function will return a `DateComoponents` object with the days attribute set to `6` (this function assumes open ended intervals).
    /// - Returns: A `DateComponents` object.
    func getDateIncrement() -> DateComponents {
        switch(self) {
        case .oneDay:
            return DateComponents(day: 1, second: -1)
        case .oneWeek:
            return DateComponents(day: 6)
        case .twoWeeks:
            return DateComponents(day: 13)
        case .oneMonth:
            return DateComponents(month: 1, day: -1)
        case .threeMonths:
            return DateComponents(month: 3, day: -1)
        case .oneYear:
            return DateComponents(year: 1, day: -1)
        }
    }
    
    /// Format a date for section headers.
    /// - Parameters:
    ///   - date: A date.
    ///   - withYear: Whether to include the year.
    /// - Returns: The formatted date string.
    private func formatDateForHeader(_ date: Date, withYear: Bool = false) -> String {
        let style = Date.FormatStyle.dateTime.day().month(.abbreviated)
        
        if withYear {
            return "\(date.formatted(style)) '\(date.formatted(.dateTime.year(.twoDigits)))"
        }
        
        return date.formatted(style)
    }
    
    /// Get a formatted string for a given date interval and user selected time period.
    /// - Parameters:
    ///   - dateInterval: A date interval.
    /// - Returns: A formatted string for the date interval.
    func getDateIntervalLabel(for dateInterval: DateInterval) -> String {
        switch(self) {
        case .oneDay:
            return formatDateForHeader(dateInterval.start, withYear: true)
        case .oneWeek, .twoWeeks, .threeMonths:
            let start = formatDateForHeader(dateInterval.start)
            let end = formatDateForHeader(dateInterval.end, withYear: true)
            
            return "\(start) - \(end)"
        case .oneMonth:
            let month = dateInterval.start.formatted(.dateTime.month())
            let year = dateInterval.start.formatted(.dateTime.year(.twoDigits))
            
            return "\(month) '\(year)"
        case .oneYear:
            return dateInterval.start.formatted(.dateTime.year())
        }
    }
}
