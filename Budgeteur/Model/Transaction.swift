//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    var amount: Double {
        didSet {
            if amount < 0 {
                amount = oldValue
            }
        }
    }
    var date = Date.now
    var description: String = ""
    
    static let currencyFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = NSLocale.current
        
        return formatter
    }()
    
    var formattedAmount: String {
        Transaction.currencyFormatter.string(from: amount as NSNumber) ?? "NaN"
    }
    
    var shortDate: String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }
    
    static var sample: Transaction {
        Transaction(amount: 10000, description: "A huge diamond")
    }
}
