//
//  TransactionDetail.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Form for editing an existing transaction, or deleting it.
struct TransactionEditorOld: View {
    @Binding var categories: [UserCategoryClass]
    @Binding var transaction: TransactionClass
    /// A function to run if the user presses the cancel button in the toolbar.
    var onCancel: () -> ()
    /// A function to run if the user presses the save button in the toolbar.
    var onSave: () -> ()
    /// A function that stops a recurring transaction.
    var stopRecurring: (_ transaction: TransactionClass) -> ()
    
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
                CategorySelectorOld(categories: $categories, selectedCategory: $transaction.categoryID)
                    .padding(.horizontal, -20)
            }
            
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, formatter: TransactionEditorOld.numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            Section("Date") {
                DatePicker("Date", selection: $transaction.date, displayedComponents: [.date])
                    .labelsHidden()
            }
            
            Section("Repeats") {
                RecurrencePeriodPicker(recurrencePeriod: $transaction.recurrencePeriod)
            }
            
            if transaction.recurrencePeriod != .never {
                Button("Stop Recurring", role: .destructive) {
                    stopRecurring(transaction)
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave()
                }
            }
        }
    }
}

struct TransactionEditorOld_Previews: PreviewProvider {
    static var data = DataModel()
    
    static var previews: some View {
        NavigationStack {
            TransactionEditorOld(
                categories: .constant(data.categories),
                              transaction: .constant(data.transactions.last!),
                onCancel: {},
                onSave: {},
                stopRecurring: {transaction in }
            )
        }
    }
}
