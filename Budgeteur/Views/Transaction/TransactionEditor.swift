//
//  TransactionDetail.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Form for editing an existing transaction, or deleting it.
struct TransactionEditor: View {
    @ObservedObject var data: DataModel
    
    @Binding var transaction: Transaction
    /// This view will set ``isEditing`` to `false` when the user taps either the cancel or save buttons.
    @Binding var isEditing: Bool
    
    static private let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
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
                    data.updateTransaction(transaction)
                    isEditing = false
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            List {
                Section("Description"){
                    TextField("Description", text: $transaction.description, axis: .vertical)
                }
                
                Section("Tag") {
                    CategorySelector(data: data, selectedCategory: $transaction.category)
                }
                
                Section("Amount") {
                    TextField("Amount", value: $transaction.amount, formatter: TransactionEditor.numberFormatter)
                        .keyboardType(.decimalPad)
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
                        .labelsHidden()
                }
                
                Button("Delete", role:.destructive) {
                    data.removeTransaction(transaction)
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
        TransactionEditor(data: data,
                          transaction: .constant(data.transactions[0]),
                          isEditing: .constant(true))
    }
}
