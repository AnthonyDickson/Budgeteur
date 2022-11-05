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
    var getCategoryName: (_ categoryID: UUID?) -> String
    
    /// Text describing how much was spent on what (category).
    private var amountText: String {
        let amountString = Currency.format(transaction.amount)
        let categoryName = getCategoryName(transaction.categoryID)
        
        if categoryName != UserCategoryClass.defaultName {
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
    static var data = DataModel()
    
    static var previews: some View {
        let transaction = data.transactions[0]
        let recurringTransaction = RecurringTransaction(
            amount: transaction.amount,
            description: transaction.description,
            categoryID: transaction.categoryID,
            date: transaction.date,
            recurrencePeriod: transaction.recurrencePeriod,
            parentID: transaction.id
        )
        
        RecurringTransactionRow(transaction: recurringTransaction, getCategoryName: data.getCategoryName)
    }
}
