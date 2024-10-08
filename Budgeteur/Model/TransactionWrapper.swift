//
//  TransactionItem.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

/// Proxy object to display ``Transaction`` instances in the GUI. It can hold one-off transactions and the auto-generated recurring transactions.
struct TransactionWrapper: Identifiable {
    /// A unique identifier for the transaction, or the auto-generated recurring transaction.
    let id: UUID = .init()
    /// How much money was spent/earned.
    var amount: Double
    /// What percent of the amount is put aside as savings. **Note:** Only applicable to income transactions.
    var savings: Double
    /// Whether money was spent or earned.
    var type: TransactionType
    /// A description of the cash flow.
    var label: String
    /// When the transaction ocurred.
    var date: Date
    /// When the recurring transaction should end. If `nil`, the transaction will recur indefinitely.
    ///
    /// When set, it will always be set the date to one second before midnight on the given date.
    var endDate: Date? {
        didSet {
            if let unwrappedDate = endDate {
                endDate = Calendar.current.endOfDay(for: unwrappedDate)
            }
        }
    }
    /// How often the transaction repeats, if ever.
    var recurrencePeriod: RecurrencePeriod
    /// The category that the transaction fits into (e.g., home expenses vs. entertainment).
    var category: UserCategory?
    /// The transaction that the proxy transaction was created from.
    let parent: Transaction
    
    /// Syncs the changes made to the proxy with the underlying object in Core Data.
    ///
    /// **Note**: Does not save changes to the Core Data store.
    func update() {
        parent.amount = amount
        parent.savings = savings
        parent.type = type.rawValue
        parent.label = label
        parent.date = date
        parent.endDate = endDate
        parent.recurrencePeriod = recurrencePeriod.rawValue
        parent.category = category
    }
    
    /// Create a ``TransactionWrapper`` from a ``Transaction`` object.
    /// - Parameter parent: A ``Transaction`` object.
    /// - Returns: A new ``TransactionWrapper``.
    static func fromTransaction(_ parent: Transaction) -> TransactionWrapper {
        return TransactionWrapper(
            amount: parent.amount,
            savings: parent.savings,
            type: TransactionType(rawValue: parent.type)!,
            label: parent.label,
            date: parent.date,
            recurrencePeriod: RecurrencePeriod(rawValue: parent.recurrencePeriod)!,
            category: parent.category,
            parent: parent
        )
    }
}
