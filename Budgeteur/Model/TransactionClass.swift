//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

protocol TransactionProtocol: Identifiable {
    /// A unique identifier for the transaction.
    var id: UUID { get }
    /// How much money was spent/earned.
    var amount: Double { get }
    /// A description of the cash flow.
    var description: String { get }
    /// The ID category that the transaction fits into (e.g., home expenses vs. entertainment).
    var categoryID: UUID? { get }
    /// When the transaction occured.
    var date: Date { get }
    /// How often the transaction repeats, if ever.
    var recurrencePeriod: RecurrencePeriod { get }
}

extension TransactionProtocol {
    /// The day and month in an abbreviated format, e.g. `2022-10-09` -> `Oct 9`
    var shortDate: String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }
}

/// A expense or income that repeats on a regular basis, e.g. rent.
///
/// Used for auto-generated transcation rows.
struct RecurringTransaction: TransactionProtocol {
    let id = UUID()
    let amount: Double
    let description: String
    let categoryID: UUID?
    let date: Date
    let recurrencePeriod: RecurrencePeriod
    /// The ID of the ``Transaction`` this recurring transaction was generated from.
    let parentID: UUID
}

/// Represents an expenditure or income.
struct TransactionClass: TransactionProtocol {
    let id = UUID()
    var amount: Double {
        didSet {
            if amount < 0 {
                amount = oldValue
            }
        }
    }
    var description: String = ""
    var categoryID: UUID?
    var date = Date.now
    var recurrencePeriod = RecurrencePeriod.never
    
    /// A sample transaction.
    static var sample: TransactionClass {
        TransactionClass(amount: 10000, description: "A huge diamond")
    }
}
