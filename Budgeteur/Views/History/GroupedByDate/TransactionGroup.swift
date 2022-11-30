//
//  TransactionGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroup: View {
    /// The text that appears in the section header.
    var title: String
    /// The set of one-off and recurring transactions to display.
    var transactionSet: TransactionSet
    /// The time interval to group transactions into (e.g., 1 day, 1 week).
    var period: Period
    
    var body: some View {
        Section {
            VStack {
                TransactionGroupHeader(title: title, totalIncome: transactionSet.sumIncome, totalExpenses: transactionSet.sumExpenses)
                
                if period == .oneDay && transactionSet.oneOffTransactions.count > 0 {
                    Divider()
                }
            }
            
            ForEach(transactionSet.groupOneOffByDate(), id: \.key) { date, transactions in
                if period == .oneDay {
                    TransactionRows(transactions: transactions, useDateForHeader: false)
                } else {
                    TransactionByDateSubGroup(date: date, transactions: transactions)
                }
            }
            
            if transactionSet.recurringTransactions.count > 0 {
                RecurringTransactionSubGroup(recurringTransactions: transactionSet.recurringTransactions)
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct TransactionGroup_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m = DataManager.init(inMemory: true)
        m.addSampleData(numSamples: 250)
        return m
    }()
    
    static var previews: some View {
        ForEach([Period.oneWeek, Period.oneDay], id: \.self) { period in
            let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
            let (dateInterval, transactionSet) = TransactionSet.fromTransactions(transactions, groupBy: period)
                .groupByDateInterval(period: period)[0]
            let title = period.getDateIntervalLabel(for: dateInterval)
            
            List {
                TransactionGroup(title: title, transactionSet: transactionSet, period: period)
            }
            .previewDisplayName(period.rawValue)
        }
    }
}
