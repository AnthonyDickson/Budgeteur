//
//  UserCategory+CoreDataProperties.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//
//

import Foundation
import CoreData


extension UserCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCategory> {
        return NSFetchRequest<UserCategory>(entityName: "UserCategory")
    }

    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var transactionsWithCategory: NSSet?
    
    static let defaultName = "Untagged"
    
    public convenience init(insertInto context: NSManagedObjectContext, name: String, type: TransactionType) {
        guard let entity = NSEntityDescription.entity(forEntityName: "UserCategory", in: context) else {
            fatalError("Could not get entity description for 'UserCategory'.")
        }
        
        self.init(entity: entity, insertInto: context)
        
        self.name = name
        self.type = type.rawValue
    }
}

// MARK: Generated accessors for transactionsWithCategory
extension UserCategory {

    @objc(addTransactionsWithCategoryObject:)
    @NSManaged public func addToTransactionsWithCategory(_ value: Transaction)

    @objc(removeTransactionsWithCategoryObject:)
    @NSManaged public func removeFromTransactionsWithCategory(_ value: Transaction)

    @objc(addTransactionsWithCategory:)
    @NSManaged public func addToTransactionsWithCategory(_ values: NSSet)

    @objc(removeTransactionsWithCategory:)
    @NSManaged public func removeFromTransactionsWithCategory(_ values: NSSet)

}

extension UserCategory : Identifiable {

}
