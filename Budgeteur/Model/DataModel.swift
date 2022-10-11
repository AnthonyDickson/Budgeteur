//
//  DataModel.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation
import GameplayKit

/// A container for the app's data.
final class DataModel: ObservableObject {
    // MARK: - User Categories
    /// User defined categories for expenses.
    @Published var categories: [UserCategory] = [
        UserCategory(name: "Groceries 🍎"),
        UserCategory(name: "Eating Out 🍔"),
        UserCategory(name: "Home Expenses 🏡"),
        UserCategory(name: "Entertainment 🎶"),
        UserCategory(name: "Donation ❤️")
    ]

    // MARK: - Transactions

    /// A collection of transactions
    ///
    /// Transactions are sorted by date in descending order, however this is not guaranteed if the transactions collection is modified directly.
    /// The methods ``addTransaction(_:)``, ``removeTransaction(_:)`` and ``updateTransaction(_:)`` should be used to modify this collection.
    @Published var transactions = {
        var sampleTransactions: [Transaction] = []
        var rng = GKMersenneTwisterRandomSource(seed: 42)
        let descriptions = [
            "Foo",
            "Bar",
            "Bat",
            "Baz",
            "Fizz",
            "Pop"
        ]
        let startDate = ISO8601DateFormatter().date(from: "2022-10-09T00:00:00Z")!
        
        for index in 0...25 {
            let description = descriptions[rng.nextInt(upperBound: descriptions.count)]
            let amount = 100.0 * Double(rng.nextUniform())
            let date = Calendar.current.date(
                byAdding: Calendar.Component.day,
                value: -index * rng.nextInt(upperBound: 5),
                to: startDate)!
            
            sampleTransactions.append(Transaction(
                amount: amount,
                description: description,
                date: date
            ))
        }
        
        return sampleTransactions.sorted(by: { $0.date > $1.date })
    }()
    
    /// Add a transaction to the collection of transactions.
    ///
    /// This method ensures the transactions stays sorted by date in descending order.
    func addTransaction(_ transaction: Transaction) {
        // TODO: Use binary search to make this faster.
        let insertionIndex = transactions.firstIndex(where: { transaction.date > $0.date }) ?? transactions.count
        transactions.insert(transaction, at: insertionIndex)
    }
    
    /// Find the index of a transaction.
    fileprivate func indexOf(_ transaction: Transaction) -> Array<Transaction>.Index? {
        // TODO: Use binary search to make this faster.
        return transactions.firstIndex(where: { $0.id == transaction.id })
    }
    
    /// Remove a transaction from the collection of transactions.
    func removeTransaction(_ transaction: Transaction) {
        guard let index = indexOf(transaction) else {
            // TODO: Should some indication that the transaction be given (e.g. Bool return value or throw error)?
            return
        }
        
        transactions.remove(at: index)
    }
    
    /// Update a transaction.
    ///
    /// The ID of `transaction` must match the ID of a transaction in the collection.
    /// Otherwise the old transaction will not be removed and the new transaction will still be added.
    func updateTransaction(_ transaction: Transaction) {
        removeTransaction(transaction)
        addTransaction(transaction)
    }
}
