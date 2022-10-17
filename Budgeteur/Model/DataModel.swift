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
    
    var oneOffTransactions: [Transaction] { transactions.filter({ $0.recurrencePeriod == .never }) }
    var repeatTransactions: [Transaction] { transactions.filter({ $0.recurrencePeriod != .never }) }
    
    /// Add a transaction to the collection of transactions.
    ///
    /// This method ensures the transactions stays sorted by date in descending order.
    func addTransaction(_ transaction: Transaction) {
        // TODO: Use binary search to make this faster.
        let insertionIndex = transactions.firstIndex(where: { transaction.date >= $0.date }) ?? transactions.count
        transactions.insert(transaction, at: insertionIndex)
    }
    
    /// Get a transaction by ID.
    /// - Parameter uuid: The ID to search for.
    /// - Returns: A transction whose ID matches the given ID.
    func getTransaction(by uuid: UUID) -> Transaction? {
        // TODO: Use binary search to make this faster.
        if let transaction = transactions.first(where: { $0.id == uuid }) {
            return transaction
        }
        
        return nil
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
    
    // MARK: - Recurring Transactions
    
    /// Get the contribution to expenses/income that recurring transaction for a given time period.
    /// - Parameter dateInterval: The time period to consider.
    /// - Returns: A list of proxy transactions.
    func getRecurringTransactions(for dateInterval: DateInterval) -> [RecurringTransaction] {
        let multipliers = [
            RecurrencePeriod.daily: 1.0,
            RecurrencePeriod.weekly: 52.1785/365.25,
            RecurrencePeriod.fortnighly: 26.0892/365.25,
            RecurrencePeriod.monthly: 12/365.25,
            RecurrencePeriod.quarterly: 3/365.25,
            RecurrencePeriod.yearly: 1/365.25
        ]
        
        var repeatTransactions: [RecurringTransaction] = []
        
        for transaction in transactions {
            guard transaction.recurrencePeriod != .never else {
                continue
            }
            
            let transactionDate = Calendar.current.startOfDay(for: transaction.date)
            let repeatStartedAfterInterval = transactionDate > dateInterval.start
            let startDate = repeatStartedAfterInterval ? transactionDate : dateInterval.start
            let startDateBeforeEnd = startDate < dateInterval.end
            
            guard startDateBeforeEnd else {
                continue
            }
            
            // The date intervals are closed intervals, but the .day component returns the length of the open interval so we need to add one to the result.
            let numDays = Calendar.current.dateComponents([.day], from: startDate, to: dateInterval.end).day! + 1
            let dailyAmount = transaction.amount * multipliers[transaction.recurrencePeriod]!
            let amountForPeriod = dailyAmount * Double(numDays)
            
            repeatTransactions.append(RecurringTransaction(
                amount: amountForPeriod,
                description: transaction.description,
                categoryID: transaction.categoryID,
                date: Date.now,
                recurrencePeriod: transaction.recurrencePeriod,
                parentID: transaction.id
            ))
        }
        
        return repeatTransactions
    }
    
    /// Remove recurring transactions given a set of indices and a list of recurring transactions.
    ///
    /// This function will remove the parent transaction of each recurring transactions.
    /// - Parameters:
    ///   - indexSet: The indices of the transactions to remove from `recurringTransactons`.
    ///   - recurringTransactions: The list of recurring transactions.
    func removeRecurringTransactions(atOffsets indexSet: IndexSet, from recurringTransactions: [RecurringTransaction]) {
        var indices: [Int] = []
        
        for index in indexSet {
            let parentID = recurringTransactions[index].parentID
            
            // TODO: Use binary search to make this faster.
            if let parentIndex = transactions.firstIndex(where: { $0.id == parentID }) {
                indices.append(parentIndex)
            }
        }
        
        transactions.remove(atOffsets: IndexSet(indices))
    }
    
    // MARK: - Initialisers
    
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
        let startDate = Date.now
        
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
        
        sampleTransactions.append(Transaction(
            amount: 255.0,
            description: "Rent",
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            categoryID: categories[2].id,
            recurrencePeriod: .weekly
        ))
        
        sampleTransactions.append(Transaction(
            amount: 15.0,
            description: "Netflix",
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            categoryID: categories[3].id,
            recurrencePeriod: .monthly
        ))
        
        let transactions = sampleTransactions.sorted(by: { $0.date > $1.date })
        
        self.init(categories: categories, transactions: transactions)
    }
}
