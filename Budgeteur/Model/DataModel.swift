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
    
    func addSampleData(numSamples: Int = 50, addRecurring: Bool = true) {
        let categories = [
            createUserCategory(name: "Groceries 🛒"),
            createUserCategory(name: "Eating Out 🍔"),
            createUserCategory(name: "Home Expenses 🏡"),
            createUserCategory(name: "Entertainment 🎶"),
            createUserCategory(name: "Donation ❤️")
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
        
        for index in 0..<numSamples {
            let description = descriptions[rng.nextInt(upperBound: descriptions.count)]
            let amount = 100.0 * Double(rng.nextUniform())
            let date = Calendar.current.date(
                byAdding: Calendar.Component.day,
                value: -index * rng.nextInt(upperBound: 5),
                to: startDate)!
            let category = categories[rng.nextInt(upperBound: categories.count)]
            
            _ = createTransaction(
                amount: amount,
                label: description,
                date: date,
                category: category
            )
        }
        
        
        if addRecurring {
            _ = createTransaction(
                amount: 255.0,
                label: "Rent",
                date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
                recurrencePeriod: .weekly,
                category: categories[2]
            )
            
            _ = createTransaction(
                amount: 15.0,
                label: "Netflix",
                date: Calendar.current.date(byAdding: .month, value: -3, to: startDate)!,
                recurrencePeriod: .monthly,
                category: categories[3]
            )
        }
    }
    
    /// Delete everything in the Core Data store.
    func deleteAll() {
        let categories = try? context.fetch(UserCategory.fetchRequest())
        let transactions = try? context.fetch(Transaction.fetchRequest())
        
        categories?.forEach { context.delete($0) }
        transactions?.forEach { context.delete($0) }
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
    
    func createTransaction(amount: Double, type: TransactionType = .expense, label: String = "", date: Date = Date.now, recurrencePeriod: RecurrencePeriod = .never, category: UserCategory? = nil) -> Transaction {
        return Transaction(insertInto: context, amount: amount, type: type, label: label, date: date, recurrencePeriod: recurrencePeriod, userCategory: category)
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
    
    func updateTransaction(transaction: Transaction, amount: Double, type: TransactionType, label: String, date: Date, recurrencePeriod: RecurrencePeriod, category: UserCategory?) {
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.label = label
        transaction.date = date
        transaction.recurrencePeriod = recurrencePeriod.rawValue
        transaction.category = category
        
        save()
    }
    
    func updateTransaction(transaction: TransactionWrapper) {
        transaction.update()
        save()
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
