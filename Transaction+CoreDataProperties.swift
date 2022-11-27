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

    @NSManaged public var amount: Double
    @NSManaged public var type: String
    @NSManaged public var label: String
    @NSManaged public var date: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var recurrencePeriod: String
    @NSManaged public var category: UserCategory?
    
    public convenience init(insertInto context: NSManagedObjectContext, amount: Double, type: TransactionType = .expense, label: String = "", date: Date = .now, endDate: Date? = nil, recurrencePeriod: RecurrencePeriod = .never, userCategory: UserCategory?) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Could not get entity description for 'Transaction'.")
        }
        
        self.init(entity: entity, insertInto: context)
        
        self.amount = amount
        self.type = type.rawValue
        self.label = label
        self.date = date
        self.endDate = endDate
        self.recurrencePeriod = recurrencePeriod.rawValue
        self.category = userCategory
        self.category?.addToTransactionsWithCategory(self)
    }
}

extension Transaction : Identifiable {

}
