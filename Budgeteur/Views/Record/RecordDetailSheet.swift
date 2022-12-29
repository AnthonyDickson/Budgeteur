//
//  RecordDetailSheet.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

/// Form for selecting the data and the recurrence period of a transaction.
struct RecordDetailSheet: View {
    /// When the transaction occured.
    @Binding var date: Date
    /// How often the transaction repeats, if ever.
    @Binding var recurrencePeriod: RecurrencePeriod
    
    /// How much money was spent/earned.
    var amount: Double
    /// What percent of the amount is put aside as savings. **Note:** Only applicable to income transactions.
    @Binding var savings: Double
    /// Whether money was spent or earned.
    var transactionType: TransactionType
    
    var body: some View {
        // TODO: Stop longer repeat period names from moving date column.
        Grid(alignment: .center) {
            if transactionType == .income {
                GridRow {
                    Text("Budget")
                        .font(.headline)
                }
                .gridCellColumns(2)
                .padding()
                
                GridRow {
                    SavingsEditor(amount: amount, savings: $savings)
                }
                .gridCellColumns(2)
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            GridRow {
                // The trailing padding is needed to center the text over the button.
                Label("Date", systemImage: "calendar")
                    .padding(.trailing)
                Label("Repeat", systemImage: "repeat")
            }
            
            GridRow {
                DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .padding(.trailing)
                RecurrencePeriodPicker(recurrencePeriod: $recurrencePeriod, allowNever: true)
            }
        }
        .padding(.top)
        .presentationDetents([.medium, .height(transactionType == .income ? 256 : 128)])
    }
}

struct RecordDetailSheet_Previews: PreviewProvider {
    private struct PreviewData {
        var date: Date
        var recurrencePeriod: RecurrencePeriod
        var amount: Double
        var savings: Double
    }
    
    static var previews: some View {
        let previewData = PreviewData(date: .now, recurrencePeriod: .weekly, amount: 69.0, savings: 0.5)

        Stateful(initialState: previewData) { $data in
            ForEach([TransactionType.expense, TransactionType.income], id: \.self) { transactionType in
                RecordDetailSheet(date: $data.date, recurrencePeriod: $data.recurrencePeriod, amount: data.amount, savings: $data.savings, transactionType: transactionType)
                    .previewDisplayName(transactionType.rawValue)
            }
        }
    }
}
