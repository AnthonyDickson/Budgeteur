//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

struct Transaction: Identifiable {
    var id = UUID()
    var amount: Double
    var date: Date
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
    
    static let sample = Transaction(amount: 10000, date: Date.now, description: "A huge diamond")
}
