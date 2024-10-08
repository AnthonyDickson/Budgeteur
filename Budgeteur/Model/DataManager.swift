//
//  DataModel.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation
import CoreData

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

/// Loads and saves the Core Data store and also handles de
class DataManager: ObservableObject {
    static private let groupIdentifier = "group.com.dican732.Budgeteur"
    
    /// The Core Data stack.
    let container = NSPersistentCloudKitContainer(name: "Budgeteur")
    /// The view context of the ``DataManager``'s ``container``.
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private static var groupStoreUrl: URL? {
        let groupContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.groupIdentifier)
        return groupContainerUrl?.appending(path: "Budgeteur.sqlite")
    }
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: URL(filePath: "/dev/null"))]
        } else {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: Self.groupStoreUrl!)]
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    /// A ``DataManager`` instance that contains mock data.
    static var preview: DataManager = {
       let m = DataManager(inMemory: true)
        
        m.addSampleData(numSamples: 500, addRecurring: true)
        m.save()
        
        return m
    }()
    
    /// Add mock data (categories and transactions) to the context.
    ///
    /// This function does not save the changes, call ``save()`` to make the added transactions and categories permanent.
    /// - Parameters:
    ///   - numSamples: How many transactions to add.
    ///   - addRecurring: Whether to add recurring transactions.
    func addSampleData(numSamples: Int = 50, addRecurring: Bool = true) {
        let categories = [
            UserCategory(insertInto: context, name: "🛒 Groceries", type: .expense),
            UserCategory(insertInto: context, name: "🍔 Eating Out", type: .expense),
            UserCategory(insertInto: context, name: "🏡 Home Expenses", type: .expense),
            UserCategory(insertInto: context, name: "🎶 Entertainment", type: .expense),
            UserCategory(insertInto: context, name: "❤️ Donation", type: .expense)
        ]
        
        let descriptions = [
            "Foo",
            "Bar",
            "Bat",
            "Baz",
            "Fizz",
            "Pop"
        ]
        let startDate = Date.now
        var rng = RandomNumberGeneratorWithSeed(seed: 42)
        
        for _ in 0..<numSamples {
            let amount = Double.random(in: 0...100, using: &rng)
            
            let descriptionIndex = Int.random(in: 0..<descriptions.count, using: &rng)
            let description = descriptions[descriptionIndex]
            
            let dayOffset = -Int.random(in: 0...365, using: &rng)
            let date = Calendar.current.date(
                byAdding: Calendar.Component.day,
                value: dayOffset,
                to: startDate)!
            
            let categoryIndex = Int.random(in: 0..<categories.count, using: &rng)
            let category = categories[categoryIndex]
            
            _ = Transaction(
                insertInto: context,
                amount: amount,
                type: .expense,
                label: description,
                date: date,
                userCategory: category
            )
        }
        
        
        if addRecurring {
            let minusOneYear = Calendar.current.date(byAdding: DateComponents(year: -1), to: startDate)!
            
            _ = Transaction(
                insertInto: context,
                amount: 255.0,
                label: "Rent",
                date: minusOneYear,
                recurrencePeriod: .weekly,
                userCategory: categories[2]
            )
            
            _ = Transaction(
                insertInto: context,
                amount: 15.0,
                label: "Netflix",
                date: minusOneYear,
                recurrencePeriod: .monthly,
                userCategory: categories[3]
            )
            
            _ = Transaction(
                insertInto: context,
                amount: 800.0,
                savings: 0.25,
                type: .income,
                label: "Wages",
                date: minusOneYear,
                recurrencePeriod: .weekly,
                userCategory: UserCategory(insertInto: context, name: "💰 Income", type: .income)
            )
        }
    }
    
    /// Delete everything in the Core Data store.
    ///
    /// This function does not save the changes, call ``save()`` to make the changes permanent.
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
}
