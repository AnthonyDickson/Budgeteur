//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Displays the details of transactions in a vertical list.
struct TransactionList: View {
    /// The app's data model.
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
        .navigationTitle("History")
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                TransactionEditor(categories: $data.categories,
                                  transaction: $selectedTransaction)
                .navigationTitle("Edit Transaction")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button("Cancel", role: .cancel) {
                            isEditing = false
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            data.updateTransaction(selectedTransaction)
                            isEditing = false
                        }
                    }
                }
            }
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TransactionList(data: DataModel())
        }
    }
}
