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
    @Published var groupByCategory: Bool = false
    /// The period to aggregate expenses/income into.
    @Published var period: Period = .oneWeek

    // MARK: - User Categories
    /// User defined categories for expenses.
    @Published var categories: [UserCategory]
    
    /// Retreive the name of a category it it exists, otherwise a suitable default value.
    /// - Parameter categoryID: The ID of the category.
    /// - Returns: The name of the category, or a suitable default value.
    func getCategoryName(_ categoryID: UUID?) -> String {
        guard let categoryID = categoryID else { return UserCategory.defaultName }
        
        return categories.first(where: { $0.id == categoryID })?.name ?? UserCategory.defaultName
    }

    // MARK: - Transactions

    /// A collection of transactions
    ///
    /// Transactions are sorted by date in descending order, however this is not guaranteed if the transactions collection is modified directly.
    /// The methods ``addTransaction(_:)``, ``removeTransaction(_:)`` and ``updateTransaction(_:)`` should be used to modify this collection.
    @Published var transactions: [Transaction] = []
    
    /// Add a transaction to the collection of transactions.
    ///
    /// This method ensures the transactions stays sorted by date in descending order.
    func addTransaction(_ transaction: Transaction) {
        // TODO: Use binary search to make this faster.
        let insertionIndex = transactions.firstIndex(where: { transaction.date >= $0.date }) ?? transactions.count
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
    
    /// Create the data model with the supplied data.
    /// - Parameters:
    ///   - categories: Categories for expenses/income.
    ///   - transactions: The initial list of transactions.
    init(categories: [UserCategory], transactions: [Transaction]) {
        self.categories = categories
        self.transactions = transactions
    }
    
    /// Creates the data model with sample data.
    convenience init() {
        let categories = [
            UserCategory(name: "Groceries 🍎"),
            UserCategory(name: "Eating Out 🍔"),
            UserCategory(name: "Home Expenses 🏡"),
            UserCategory(name: "Entertainment 🎶"),
            UserCategory(name: "Donation ❤️")
        ]
        
        var sampleTransactions: [Transaction] = []
        let rng = GKMersenneTwisterRandomSource(seed: 42)
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
            let category = categories[rng.nextInt(upperBound: categories.count)]
            
            sampleTransactions.append(Transaction(
                amount: amount,
                description: description,
                date: date,
                categoryID: category.id
            ))
        }
        
        let transactions = sampleTransactions.sorted(by: { $0.date > $1.date })
        
        self.init(categories: categories, transactions: transactions)
    }
}
