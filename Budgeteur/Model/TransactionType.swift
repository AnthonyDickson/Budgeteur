//
//  TransactionType.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/11/22.
//

import Foundation

/// The kind of transaction.
public enum TransactionType: String {
    /// A transaction where money was spent.
    case expense = "Expense"
    /// A transaction where money was earned.
    case income = "Income"
}
