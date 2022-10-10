//
//  Currency.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import Foundation

/// Wrapper class for currency formatting methods.
final class Currency {
    /// Formatter for currrency in the user's locale.
    static let formatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        
        return formatter
    }()
    
    /// Format a double as a currency.
    /// - Parameter number: A floating point number.
    /// - Returns: The formatted currency string. Returns "NaN" if `number` could not be converted to a `NSNumber`.
    static func format(_ number: Double) -> String {
        formatter.string(for: number as NSNumber) ?? "NaN"
    }
}
