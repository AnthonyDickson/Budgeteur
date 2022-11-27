//
//  Calendar.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/11/22.
//

import Foundation

extension Calendar {
    /// Returns the first moment before midnight of the given Date, as a Date.
    /// - Parameter date: A date.
    /// - Returns: One second before midnight of the given date.
    func endOfDay(for date: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
        
        return endOfDay
    }
}
