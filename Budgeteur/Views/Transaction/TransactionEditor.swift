//
//  TransactionDetail.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct TransactionEditor: View {
    @Binding var transactions: [Transaction]
    @Binding var transaction: Transaction
    @Binding var isEditing: Bool
    
    var transactionIndex: Int {
        transactions.firstIndex(where: { $0.id == transaction.id })!
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Button("Cancel", role: .cancel) {
                    isEditing = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Text("Edit Transaction")
                    .font(.headline)
                
                Spacer()
                
                Button("Save") {
                    transactions[transactionIndex] = transaction
                    isEditing = false
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            List {
                Section("Description"){
                    TextField("Description", text: $transaction.description, axis: .vertical)
                }
                
                Section("Amount") {
                    TextField("Amount", value: $transaction.amount, formatter: Transaction.currencyFormatter)
                        .keyboardType(.decimalPad)
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
                        .labelsHidden()
                }
                
                Button("Delete", role:.destructive) {
                    transactions.remove(at: transactionIndex)
                    isEditing = false
                }
                
                .frame(maxWidth: .infinity)
            }
            .listStyle(.grouped)
        }
    }
}

struct TransactionEditor_Previews: PreviewProvider {
    static var data = DataModel()
    
    static var previews: some View {
        TransactionEditor(transactions: .constant(data.transactions),
                          transaction: .constant(data.transactions[0]),
                          isEditing: .constant(true))
    }
}
