//
//  RepeatPeriod.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import Foundation

/// The time period that a transaction may repeat over.
enum RecurrencePeriod: String, CaseIterable {
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
}
