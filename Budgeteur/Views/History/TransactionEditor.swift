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
    @State var transaction: TransactionWrapper
    
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
                CategoryPicker(selectedCategory: $transaction.category, transactionType: transaction.type)
                    .padding(.horizontal, -20)
            }
            
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, formatter: TransactionEditor.numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            if transaction.type == .income {
                Section("Budget") {
                    SavingsEditor(amount: transaction.amount, savings: $transaction.savings)
                }
            }

            Section(dateSectionLabel) {
                DatePicker(dateSectionLabel, selection: $transaction.date, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
            }
            
            if isRecurringTransaction {
                Section("End Date") {
                    OptionalDatePicker(date: $transaction.endDate, dateRange: transaction.date...)
                }
                
                Section("Repeats") {
                    RecurrencePeriodPicker(
                        recurrencePeriod: $transaction.recurrencePeriod,
                        allowNever: false
                    )
                }
            }
            
            DeleteButtonWithConfirmation {
                dataManager.context.delete(transaction.parent)
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
        .navigationTitle("Edit \(transaction.type.rawValue)")
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
                    transaction.update()
                    dataManager.save()
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
        let transactionOneOff = TransactionWrapper.fromTransaction(Transaction(insertInto: dataManager.context, amount: 420.69, label: "Foo", date: Date.now, recurrencePeriod: .never))

        let transactionOneOffIncome = TransactionWrapper.fromTransaction(Transaction(insertInto: dataManager.context, amount: 420.69, savings: 0.2, type: .income, label: "Baz", date: Date.now, recurrencePeriod: .never))

        let transactionRecurring = TransactionWrapper.fromTransaction(Transaction(insertInto: dataManager.context, amount: 420.69, label: "Bar", date: Date.now, recurrencePeriod: .weekly))

        NavigationStack {
            TransactionEditor(transaction: transactionOneOff)
        }
        .previewDisplayName("One-Off Transaction")

        NavigationStack {
            TransactionEditor(transaction: transactionOneOffIncome)
        }
        .previewDisplayName("One-Off Transaction (Income)")
        
        
        NavigationStack {
            TransactionEditor(transaction: transactionRecurring)
        }
        .previewDisplayName("Recurring Transaction")
    }
}
