//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation


/// A expense or income that repeats on a regular basis, e.g. rent.
///
/// Used for auto-generated transcation rows.
struct RecurringTransaction: Identifiable {
    let id = UUID()
    /// How much money was spent/earned.
    let amount: Double
    /// A description of the cash flow.
    let description: String
    /// The ID category that the transaction fits into (e.g., home expenses vs. entertainment).
    let categoryID: UUID?
    /// How often the transaction repeats, if ever.
    let recurrencePeriod: RecurrencePeriod
    /// The ID of the ``Transaction`` this recurring transaction was generated from.
    let parentID: UUID
}

/// Represents an expenditure or income.
struct Transaction: Identifiable {
    let id = UUID()
    /// How much money was spent/earned.
    var amount: Double {
        didSet {
            if amount < 0 {
                amount = oldValue
            }
        }
    }
    /// A description of the cash flow.
    var description: String = ""
    /// When the transaction occured.
    var date = Date.now
    /// The ID category that the transaction fits into (e.g., home expenses vs. entertainment).
    var categoryID: UUID?
    /// How often the transaction repeats, if ever.
    var recurrencePeriod = RecurrencePeriod.never
    
    /// The day and month in an abbreviated format, e.g. `2022-10-09` -> `Oct 9`
    var shortDate: String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }
    
    /// A sample transaction.
    static var sample: Transaction {
        Transaction(amount: 10000, description: "A huge diamond")
    }
}
