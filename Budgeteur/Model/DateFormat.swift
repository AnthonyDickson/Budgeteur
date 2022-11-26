//
//  DateFormat.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import Foundation

final class DateFormat {
    /// Convert a date into a formatted string containing the short month and two digit day
    /// - Parameter date: The date to format.
    /// - Returns: A string of the date.
    static func format(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
    }
}
