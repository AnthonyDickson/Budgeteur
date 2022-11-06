//
//  TransactionView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//

import SwiftUI

struct TransactionView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)]) var transactions: FetchedResults<Transaction>
    
    func categoryText(transaction: Transaction) -> String {
        if let category = transaction.categoryOfTransaction {
            return " on \(category.name)"
        }
        
        return ""
    }
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(Currency.format(transaction.amount))\(categoryText(transaction: transaction))")
                        Text(transaction.label)
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
        .listStyle(.inset)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var dataManager: DataManager = .sample
    
    static var previews: some View {
        TransactionView()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
    }
}
