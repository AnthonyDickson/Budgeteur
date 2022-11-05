//
//  HistoryGroupHeader.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 22/10/22.
//

import SwiftUI

/// Displays the header of a section in the history view - this is the total spent for the period and the start + end dates of the current time period.
struct HistorySectionHeader: View {
    /// The list of transactions that occured within the specific time period.
    let transactions: [TransactionClass]
    /// The list of recurring transactions that occured within the specific time period.
    let recurringTransactions: [RecurringTransaction]
    /// The formatted string of the specific time period (date interval).
    let dateIntervalLabel: String
    /// The total amount of the regular transactions plus the recurring transactions.
    private let totalExpense: Double
    
    init(transactions: [TransactionClass], recurringTransactions: [RecurringTransaction], dateIntervalLabel: String) {
        self.transactions = transactions
        self.recurringTransactions = recurringTransactions
        self.dateIntervalLabel = dateIntervalLabel
        
        let transactionSum = transactions.reduce(0) { $0 + $1.amount }
        let recurringTransactionSum = recurringTransactions.reduce(0) { $0 + $1.amount }
        
        self.totalExpense = transactionSum + recurringTransactionSum
    }
    
    var body: some View {
        HStack {
            Text("Spent \(Currency.format(totalExpense))")
            Spacer()
            Text(dateIntervalLabel)
        }
        .frame(maxWidth: .infinity)
        .font(.headline)
        .bold()
        .foregroundColor(.primary)
    }
}

struct HistorySectionHeader_Previews: PreviewProvider {
    static var data = DataModel()
    
    static var previews: some View {
        let dateInterval = data.period.getDateInterval(for: .now)
        
        HistorySectionHeader(transactions: data.transactions.filter { dateInterval.start <= $0.date && $0.date <= dateInterval.end },
                           recurringTransactions: data.getRecurringTransactions(for: dateInterval),
                           dateIntervalLabel: data.period.getDateIntervalLabel(for: dateInterval))
    }
}
