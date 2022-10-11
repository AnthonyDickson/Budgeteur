//
//  TransactionRow.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// The details of a single transaction intended to be view inside of a List view.
struct TransactionRow: View {
    var transaction: Transaction
    
    /// Text describing how much was spent on what (category).
    private var amountText: String {
        let amountString = Currency.format(transaction.amount)
        
        if let name = transaction.category?.name {
            return "\(amountString) on \(name)"
        } else {
            return amountString
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(amountText)
                Text(transaction.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.shortDate)
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction.sample)
    }
}
