//
//  Transaction+CoreDataProperties.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var label: String
    @NSManaged public var date: Date
    @NSManaged public var recurrencePeriod: String
    @NSManaged public var categoryOfTransaction: UserCategory?
    
    public convenience init(insertInto context: NSManagedObjectContext, amount: Double, label: String = "", date: Date = .now, recurrencePeriod: RecurrencePeriod = .never, userCategory: UserCategory?) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Could not get entity description for 'Transaction'.")
        }
        
        self.init(entity: entity, insertInto: context)
        
        self.id = UUID()
        self.amount = amount
        self.label = label
        self.date = date
        self.recurrencePeriod = recurrencePeriod.rawValue
        self.categoryOfTransaction = userCategory
        self.categoryOfTransaction?.addToTransactionsWithCategory(self)
    }
}

extension Transaction : Identifiable {

}
