//
//  TransactionRow.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Displays a transaction in a horizontal layout. Intended to used within a list.
struct TransactionRow: View {
    /// The transaction to display.
    var transaction: TransactionItem
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool = false
    
    var body: some View {
        HStack {
            if useDateForHeader {
                VStack(alignment: .leading) {
                    Text(DateFormat.format(transaction.date))
                    Text(transaction.label)
                        .font(.caption)
                }
            } else if let categoryName = transaction.category?.name {
                VStack(alignment: .leading) {
                    Text(categoryName)
                    Text(transaction.label)
                        .font(.caption)
                }
            } else {
                Text(transaction.label)
            }
            Spacer()
            
            if transaction.recurrencePeriod != .never {
                Label("Recurring Transaction", systemImage: "repeat")
                    .labelStyle(.iconOnly)
            }
            
            Text(Currency.format(transaction.amount))
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        let category = dataManager.createUserCategory(name: "Category")
        let transaction = TransactionItem.fromTransaction(
            dataManager.createTransaction(
                amount: 420.69,
                label: "Item Description",
                date: Date.distantPast,
                recurrencePeriod: .never,
                category: category
            )
        )
        
        List {
            TransactionRow(transaction: transaction, useDateForHeader: false)
        }
    }
}
