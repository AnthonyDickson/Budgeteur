//
//  RepeatPeriod.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import Foundation

/// The time period that a transaction may repeat over.
public enum RecurrencePeriod: String, CaseIterable {
    case never = "Never"
    case daily = "Daily"
    case weekly = "Weekly"
    case fortnighly = "Fortnightly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    /// Get the next repeat period.
    ///
    /// Will cycle back to the start if called on the last item.
    func getNext() -> RecurrencePeriod {
        let cases = Self.allCases
        let index = cases.firstIndex(of: self)!
        let nextIndex = (index + 1) % cases.count
        
        return cases[nextIndex]
    }
    
    /// Convert a ``RecurrencePeriod`` to a corresponding `DateComponents` object.
    ///
    /// For example, `RecurrencePeriod.daily` converts to `DateComponents(day: 1)`
    /// - Returns: A `DateComponents` objects.
    func getDateComponents() -> DateComponents {
        switch(self) {
        case .never:
            return DateComponents()
        case .daily:
            return DateComponents(day: 1)
        case .weekly:
            return DateComponents(day: 7)
        case .fortnighly:
            return DateComponents(day: 14)
        case .monthly:
            return DateComponents(month: 1)
        case .quarterly:
            return DateComponents(month: 3)
        case .yearly:
            return DateComponents(year: 1)
        }
    }
}
