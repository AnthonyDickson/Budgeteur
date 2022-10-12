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
}
