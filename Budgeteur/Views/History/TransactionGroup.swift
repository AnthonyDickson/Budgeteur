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
            ForEach(transactionSet.groupOneOffByDate(), id: \.key) { date, transactions in
                if period == .oneDay {
                    TransactionRows(transactions: transactions, useDateForHeader: false)
                } else {
                    CollapsibleTransactionSection(
                        title: DateFormat.format(date),
                        transactions: transactions,
                        useDateForHeader: false,
                        showTransactions: true
                    )
                }
            }
            
            if transactionSet.recurringTransactions.count > 0 {
                // TODO: Sort by amount
                CollapsibleTransactionSection(
                    title: "Recurring Transactions",
                    transactions: transactionSet.recurringTransactions,
                    useDateForHeader: false
                )
            }
        } header: {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .label))
                Spacer()
                VStack {
                    Text(Currency.format(transactionSet.sumIncome))
                    Text(Currency.format(-transactionSet.sumExpenses))
                }
            }
        }
    }
}

struct TransactionGroup_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m = DataManager.init(inMemory: true)
        m.addSampleData()
        return m
    }()
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
        let (dateInterval, transactionSet) = TransactionSet.fromTransactions(transactions, groupBy: period)
            .groupByDateInterval(period: period)[0]
        let title = period.getDateIntervalLabel(for: dateInterval)
        
        List {
            TransactionGroup(title: title, transactionSet: transactionSet, period: period)
        }
    }
}
