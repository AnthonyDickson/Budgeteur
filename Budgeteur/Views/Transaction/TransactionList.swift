//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct TransactionList: View {
    @ObservedObject var data: DataModel
    
    @State private var isEditing = false
    @State private var selectedTransaction = Transaction.sample
    
    var body: some View {
            List {
                ForEach(data.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .onTapGesture {
                            selectedTransaction = transaction
                            isEditing = true
                        }
                }
                .onDelete { indexSet in
                    data.transactions.remove(atOffsets: indexSet)
                }
            }
            .sheet(isPresented: $isEditing) {
                TransactionEditor(transactions: $data.transactions,
                                  transaction: $selectedTransaction,
                                  isEditing: $isEditing)
            }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionList(data: DataModel())
    }
}
