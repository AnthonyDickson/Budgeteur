//
//  RecordTitleBar.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI

/// Displays the expenses for the selected period and a button that reveals extra controls.
struct RecordTitleBar: View {
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
    
    /// Whether to show the date/repitition controls.
    @State private var showControls: Bool = false
    
    /// The user selected time period for aggregating transactions.
    @AppStorage("period") private var period: Period = .oneWeek
    
    var body: some View {
        ZStack {
            BudgetOverview(period: period)
            
            HStack {
                Spacer()
                
                Button {
                    showControls = true
                } label: {
                    Label("Change date and repetition.", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showControls) {
                RecordDetailSheet(date: $date, recurrencePeriod: $recurrencePeriod, amount: amount, savings: $savings, transactionType: transactionType)
            }
        }
    }
}

struct RecordTitleBar_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = m.createTransaction(amount: 405, date: Date.now)
        _ = m.createTransaction(amount: 15, date: Date.distantPast, recurrencePeriod: .weekly)
        
        return m
    }()
    
    private struct PreviewData {
        var date: Date
        var recurrencePeriod: RecurrencePeriod
        var amount: Double
        var savings: Double
        var transactionType: TransactionType
    }
    
    static var previews: some View {
        let previewData = PreviewData(date: .now, recurrencePeriod: .weekly, amount: 40, savings: 0.2, transactionType: .income)
        
        Stateful(initialState: previewData) { $data in
            RecordTitleBar(date: $data.date, recurrencePeriod: $data.recurrencePeriod, amount: data.amount, savings: $data.savings, transactionType: data.transactionType)
                .environment(\.managedObjectContext, dataManager.context)
        }
    }
}
