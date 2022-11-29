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
    
    /// Filter a sequence of transactions based on the selected transaction filter.
    /// - Parameter transactions: The transactions to filter.
    /// - Returns: A list of the filtered transactions.
    func filter(_ transactions: any Sequence<Transaction>) -> [Transaction] {
        switch self {
        case .all:
            return Array(transactions)
        case .oneOffOnly:
            return transactions.filter { $0.recurrencePeriod == RecurrencePeriod.never.rawValue }
        case .recurringOnly:
            return transactions.filter { $0.recurrencePeriod != RecurrencePeriod.never.rawValue }
        }
    }
}
