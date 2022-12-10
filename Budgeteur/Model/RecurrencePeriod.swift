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
    case fortnightly = "Fortnightly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var days: Int {
        switch self {
        case .never:
            return 0
        case .daily:
            return 1
        case .weekly:
            return 7
        case .fortnightly:
            return 14
        case .monthly:
            return 28
        case .quarterly:
            return 84
        case .yearly:
            return 365
        }
    }
    /// Get the date increment needed such that adding the increment to another date will create a date interval corresponding to the chosen time period.
    ///  For example given ``oneWeek``,  the function will return a `DateComoponents` object with the days attribute set to `6` (this function assumes open ended intervals).
    /// - Returns: A `DateComponents` object.
    func getDateIncrement() -> DateComponents {
        switch(self) {
        case .never:
            return DateComponents(day: 0)
        case .daily:
            return DateComponents(day: 1)
        case .weekly:
            return DateComponents(day: 7)
        case .fortnightly:
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
