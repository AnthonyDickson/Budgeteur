//
//  TransactionFilter.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 29/11/22.
//

import Foundation

/// Controls which transactions as shown.
enum TransactionFilter: String, CaseIterable {
    /// Show all transactions.
    case all = "All"
    /// Show non-recurring transactions only.
    case oneOffOnly = "One-Off"
    /// Show recurring transactions only.
    case recurringOnly = "Recurring"
    
    /// Create a predicate for a fetch request to a Core Data store base on the selected transaction filter.
    /// - Parameter label: Transactions will be filtered out if neither of their `label` or `category.name` do not contain this text (case insenstive). Empty strings will be ignored.
    /// - Returns: A `NSPredicate` object.
    func getPredicate(with label: String = "") -> NSPredicate {
        var predicates: [NSPredicate] = []
        
        if !label.isEmpty {
            predicates.append(NSPredicate(format: "label CONTAINS[c] %@ OR category.name CONTAINS[c] %@", label, label))
        }
        
        switch self {
        case .oneOffOnly:
            predicates.append(NSPredicate(format: "recurrencePeriod == %@", RecurrencePeriod.never.rawValue))
        case .recurringOnly:
            predicates.append(NSPredicate(format: "recurrencePeriod != %@", RecurrencePeriod.never.rawValue))
        default:
            break
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
