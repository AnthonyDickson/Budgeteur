//
//  RepeatTransactionRow.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 15/10/22.
//

import SwiftUI

/// The details of a repeat transaction intended to be view inside of a List view.
struct RecurringTransactionRow: View {
    var transaction: RecurringTransaction
    /// The category that the transaction belongs to. Defaults to displaying nothing.
    var categoryName: String? = nil
    
    /// Text describing how much was spent on what (category).
    private var amountText: String {
        let amountString = Currency.format(transaction.amount)
        
        if let categoryName = categoryName, categoryName != UserCategory.defaultName {
            return "\(amountString) on \(categoryName)"
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
            
            HStack {
                Text(transaction.recurrencePeriod.rawValue)
                Label(transaction.recurrencePeriod.rawValue, systemImage: "repeat")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct RecurringTransactionRow_Previews: PreviewProvider {
    static var recurringTransaction = RecurringTransaction(
        amount: 123.45,
        description: "Gottem",
        categoryID: UUID(),
        recurrencePeriod: .weekly
    )
    static var previews: some View {
        RecurringTransactionRow(transaction: recurringTransaction, categoryName: "Dee Z Nütz 🥜")
    }
}
