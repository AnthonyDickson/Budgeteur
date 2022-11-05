//
//  TransactionView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//

import SwiftUI

struct TransactionView: View {
    @FetchRequest(sortDescriptors: []) var transactions: FetchedResults<Transaction>
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                HStack {
                    VStack {
                        Text(Currency.format(transaction.amount))
                        Text(transaction.categoryOfTransaction?.name ?? "")
                        Text(transaction.label ?? "")
                    }
                    Spacer()
                    VStack {
                        Text(transaction.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                    }
                }
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var dataManager: DataManager = .sample
    
    static var previews: some View {
        TransactionView()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
    }
}
