//
//  Currency.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import Foundation

/// Wrapper class for currency formatting methods.
final class Currency {
    static var baseFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        
        return formatter
    }
    
    /// Formatter for currrency in the user's locale.
    static let formatter = baseFormatter
    
    /// Formatter for currrency in the user's locale that rounds to whole numbers.
    static let wholeFormatter = {
        let formatter = baseFormatter
        
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    /// Format a double as a currency.
    /// - Parameter number: A floating point number.
    /// - Returns: The formatted currency string. Returns "NaN" if `number` could not be converted to a `NSNumber`.
    static func format(_ number: Double) -> String {
        formatter.string(for: number as NSNumber) ?? "NaN"
    }
    
    /// Rounds number to the nearest integer and formats it as a currency.
    /// - Parameter number: A floating point number.
    /// - Returns: The formatted currency string. Returns "NaN" if `number` could not be converted to a `NSNumber`.
    static func formatAsWhole(_ number: Double) -> String {
        wholeFormatter.string(for: number as NSNumber) ?? "NaN"
    }
}
