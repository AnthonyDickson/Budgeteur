//
//  TransactionEditor.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Form for editing an existing transaction, or deleting it.
struct TransactionEditor: View {
    /// The transaction to edit.
    @State var transaction: TransactionItem
    
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    static private let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    /// Check whether the transaction we are editing is a recurring one.
    private var isRecurringTransaction: Bool {
        transaction.parent.recurrencePeriod != RecurrencePeriod.never.rawValue
    }
    
    /// Get the label for the date section which should change based on whether the transaction is  a one-off or recurring one.
    private var dateSectionLabel: String {
        isRecurringTransaction ? "Start Date" : "Date"
    }

    /// Get the end of the day (one second before midnight) for a given date.
    private func endOfDay(for date: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
    }
    
    var body: some View {
        List {
            Section("Description"){
                TextField("Description", text: $transaction.label, axis: .vertical)
            }
            
            Section("Tag") {
                CategoryPicker(selectedCategory: $transaction.category)
                    .padding(.horizontal, -20)
            }
            
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, formatter: TransactionEditor.numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            
            Section(dateSectionLabel) {
                DatePicker(dateSectionLabel, selection: $transaction.date, displayedComponents: .date)
                    .labelsHidden()
            }
            
            if isRecurringTransaction {
                // TODO: Show 'None' if no end date has been set. Tapping 'none' should bring up a date picker. If a date has been selected, there should be a 'x' button to remove the end date.
                Section("End Date") {
                    DatePicker(
                        "End Date",
                        selection: Binding<Date>(
                            get: { transaction.endDate ?? Date.now },
                            set: { transaction.endDate = endOfDay(for: $0) }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                
                Section("Repeats") {
                    RecurrencePeriodPicker(
                        recurrencePeriod: $transaction.recurrencePeriod,
                        allowNever: false
                    )
                }
            }
            
            DeleteButtonWithConfirmation {
                dataManager.deleteTransaction(transaction: transaction.parent)
                dataManager.save()
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.red)
                    Text("Delete")
                    Spacer()
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dataManager.updateTransaction(transaction: transaction)
                    dismiss()
                }
            }
        }
        .onAppear {
            if isRecurringTransaction {
                // Need to do this since TransactionItem for recurring transactions will have the amount adjusted for the current time period. The parent transaction holds the unadjusted amount.
                transaction.amount = transaction.parent.amount
                // Dates will also be for the proxy transaction, rather than the parent transaction.
                transaction.date = transaction.parent.date
                transaction.endDate = transaction.parent.endDate
            }
        }
    }
}

struct TransactionEditor_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        let transactionOneOff = TransactionItem.fromTransaction(dataManager.createTransaction(amount: 420.69, label: "Foo", date: Date.now, recurrencePeriod: .never))
        let transactionRecurring = TransactionItem.fromTransaction(dataManager.createTransaction(amount: 420.69, label: "Bar", date: Date.now, recurrencePeriod: .weekly))
        
    
        NavigationStack {
            TransactionEditor(transaction: transactionOneOff)
        }
        .previewDisplayName("One-Off Transaction")
        
        
        NavigationStack {
            TransactionEditor(transaction: transactionRecurring)
        }
        .previewDisplayName("Recurring Transaction")
    }
}
