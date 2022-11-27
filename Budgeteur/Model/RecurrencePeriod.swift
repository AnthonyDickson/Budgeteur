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
}
