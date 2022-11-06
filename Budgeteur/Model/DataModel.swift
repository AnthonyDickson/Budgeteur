//
//  DataModel.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation
import GameplayKit
import CoreData

class DataManager: ObservableObject {
    let container = NSPersistentContainer(name: "Model")
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    /// 
    static var sample: DataManager {
        let manager = DataManager(inMemory: true)
        
        let categories = [
            manager.createUserCategory(name: "Groceries 🍎"),
            manager.createUserCategory(name: "Eating Out 🍔"),
            manager.createUserCategory(name: "Home Expenses 🏡"),
            manager.createUserCategory(name: "Entertainment 🎶"),
            manager.createUserCategory(name: "Donation ❤️")
        ]
        
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
            
            _ = manager.createTransaction(
                amount: amount,
                label: description,
                date: date,
                category: category
            )
        }
        
        _ = manager.createTransaction(
            amount: 255.0,
            label: "Rent",
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            recurrencePeriod: .weekly,
            category: categories[2]
        )
        
        _ = manager.createTransaction(
            amount: 15.0,
            label: "Netflix",
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            recurrencePeriod: .monthly,
            category: categories[3]
        )
        
        return manager
    }
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: URL(filePath: "/dev/null"))]
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func save() {
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func createUserCategory(name: String) -> UserCategory {
        return UserCategory(insertInto: context, name: name)
    }
    
    func createTransaction(amount: Double, label: String = "", date: Date = Date.now, recurrencePeriod: RecurrencePeriod = .never, category: UserCategory? = nil) -> Transaction {
        return Transaction(insertInto: context, amount: amount, label: label, date: date, recurrencePeriod: recurrencePeriod, userCategory: category)
    }
    
    func getUserCategories() -> [UserCategory] {
        let request: NSFetchRequest<UserCategory> = UserCategory.fetchRequest()
        var fetchedUserCategories: [UserCategory] = []
        
        do {
            fetchedUserCategories = try context.fetch(request)
        } catch let error {
            print("Error fetching user categories \(error)")
        }
        
        return fetchedUserCategories
    }
    
    func getTransactions(category: UserCategory?) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        if let category = category {
            request.predicate = NSPredicate(format: "categoryOfTransaction = %@", category)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        var fetchedTransactions: [Transaction] = []
        
        do {
            fetchedTransactions = try context.fetch(request)
        } catch let error {
            print("Error fetching transactions \(error)")
        }
        
        return fetchedTransactions
    }
    
    func deleteUserCategory(category: UserCategory) {
        context.delete(category)
        save()
    }
    
    func deleteTransaction(transaction: Transaction) {
        context.delete(transaction)
        save()
    }
}

/// A container for the app's data.
final class DataModel: ObservableObject {
    /// The period to aggregate expenses/income into.
    @Published var period: Period = .oneWeek

    // MARK: - User Categories
    /// User defined categories for expenses.
    @Published var categories: [UserCategoryClass]
    
    /// Retreive the name of a category it it exists, otherwise a suitable default value.
    /// - Parameter categoryID: The ID of the category.
    /// - Returns: The name of the category, or a suitable default value.
    func getCategoryName(_ categoryID: UUID?) -> String {
        guard let categoryID = categoryID else { return UserCategoryClass.defaultName }
        
        return categories.first(where: { $0.id == categoryID })?.name ?? UserCategoryClass.defaultName
    }

    // MARK: - Transactions

    /// A collection of transactions
    ///
    /// Transactions are sorted by date in descending order, however this is not guaranteed if the transactions collection is modified directly.
    /// Methods such as ``addTransaction(_:)``, ``removeTransaction(_:)`` and ``updateTransaction(_:)`` should be used to modify this collection.
    @Published var transactions: [TransactionClass] = []
    
    var oneOffTransactions: [TransactionClass] { transactions.filter({ $0.recurrencePeriod == .never }) }
    var repeatTransactions: [TransactionClass] { transactions.filter({ $0.recurrencePeriod != .never }) }
    
    /// Add a transaction to the collection of transactions.
    ///
    /// This method ensures the transactions stays sorted by date in descending order.
    func addTransaction(_ transaction: TransactionClass) {
        // TODO: Use binary search to make this faster.
        let insertionIndex = transactions.firstIndex(where: { transaction.date >= $0.date }) ?? transactions.count
        transactions.insert(transaction, at: insertionIndex)
    }
    
    /// Get a transaction by ID.
    /// - Parameter uuid: The ID to search for.
    /// - Returns: A transction whose ID matches the given ID.
    func getTransaction(by uuid: UUID) -> TransactionClass? {
        // TODO: Use binary search to make this faster.
        if let transaction = transactions.first(where: { $0.id == uuid }) {
            return transaction
        }
        
        return nil
    }
    
    /// Find the index of a transaction.
    fileprivate func indexOf(_ transaction: TransactionClass) -> Array<TransactionClass>.Index? {
        // TODO: Use binary search to make this faster.
        return transactions.firstIndex(where: { $0.id == transaction.id })
    }
    
    /// Remove a transaction from the collection of transactions.
    func removeTransaction(_ transaction: TransactionClass) {
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
    func updateTransaction(_ transaction: TransactionClass) {
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
    
    /// Stop a transaction from recurring.
    ///
    /// This will delete the transaction, and create transactions to replace it.
    /// - Parameter transaction: The recurring transaction to stop.
    func stopRecurring(transaction: TransactionClass) {
        if transaction.recurrencePeriod == .never {
            return
        }
        
        var currentDate = transaction.date
        let endDate = Date.now
        let step = transaction.recurrencePeriod.getDateComponents()
        
        while currentDate < endDate {
            let newTransaction = TransactionClass(
                amount: transaction.amount,
                description: transaction.description,
                categoryID: transaction.categoryID,
                date: currentDate,
                recurrencePeriod: .never
            )
            
            addTransaction(newTransaction)
            
            currentDate = Calendar.current.date(byAdding: step, to: currentDate)!
        }
        
        removeTransaction(transaction)
    }
    
    // MARK: - Initialisers
    
    /// Create the data model with the supplied data.
    /// - Parameters:
    ///   - categories: Categories for expenses/income.
    ///   - transactions: The initial list of transactions.
    init(categories: [UserCategoryClass], transactions: [TransactionClass]) {
        self.categories = categories
        self.transactions = transactions
    }
    
    /// Creates the data model with sample data.
    convenience init() {
        let categories = [
            UserCategoryClass(name: "Groceries 🍎"),
            UserCategoryClass(name: "Eating Out 🍔"),
            UserCategoryClass(name: "Home Expenses 🏡"),
            UserCategoryClass(name: "Entertainment 🎶"),
            UserCategoryClass(name: "Donation ❤️")
        ]
        
        var sampleTransactions: [TransactionClass] = []
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
            
            sampleTransactions.append(TransactionClass(
                amount: amount,
                description: description,
                categoryID: category.id,
                date: date
            ))
        }
        
        sampleTransactions.append(TransactionClass(
            amount: 255.0,
            description: "Rent",
            categoryID: categories[2].id,
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            recurrencePeriod: .weekly
        ))
        
        sampleTransactions.append(TransactionClass(
            amount: 15.0,
            description: "Netflix",
            categoryID: categories[3].id,
            date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
            recurrencePeriod: .monthly
        ))
        
        let transactions = sampleTransactions.sorted(by: { $0.date > $1.date })
        
        self.init(categories: categories, transactions: transactions)
    }
}
