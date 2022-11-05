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

    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var label: String?
    @NSManaged public var recurrencePeriod: String?
    @NSManaged public var date: Date?
    @NSManaged public var categoryOfTransaction: UserCategory?

}

extension Transaction : Identifiable {

}
