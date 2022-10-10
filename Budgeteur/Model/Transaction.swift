//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

/// Represents an expenditure or income.
struct Transaction: Identifiable {
    let id = UUID()
    var amount: Double {
        didSet {
            if amount < 0 {
                amount = oldValue
            }
        }
    }
    var description: String = ""
    var date = Date.now
    
    /// The day and month in an abbreviated format, e.g. `2022-10-09` -> `Oct 9`
    var shortDate: String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }
    
    /// A sample transaction.
    static var sample: Transaction {
        Transaction(amount: 10000, description: "A huge diamond")
    }
}
