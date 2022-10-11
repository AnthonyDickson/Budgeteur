//
//  TransactionDetail.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Form for editing an existing transaction, or deleting it.
struct TransactionEditor: View {
    @Binding var categories: [UserCategory]
    @Binding var transaction: Transaction
    
    static private let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    var body: some View {
        List {
            Section("Description"){
                TextField("Description", text: $transaction.description, axis: .vertical)
            }
            
            Section("Tag") {
                CategorySelector(categories: $categories, selectedCategory: $transaction.category)
                    .padding(.horizontal, -20)
            }
            
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, formatter: TransactionEditor.numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            Section("Date") {
                DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
                    .labelsHidden()
            }
        }
        .listStyle(.grouped)
    }
}

struct TransactionEditor_Previews: PreviewProvider {
    static var data = DataModel()
    
    static var previews: some View {
        TransactionEditor(categories: .constant(data.categories),
                          transaction: .constant(data.transactions[0]))
    }
}
