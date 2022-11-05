//
//  BudgetOverview.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

struct BudgetOverview: View {
    /// The user selected time period for aggregating transactions.
    var period: Period
    /// The transaction data.
    var transactions: [TransactionClass]
    /// A function that gets the recurring transactions for a given date interval.
    var getRecurringTransactions: (_ dateInterval: DateInterval) -> [RecurringTransaction]
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private var totalSpending: Double {
        let dateInterval = period.getDateInterval(for: Date.now)
        let recurringTransactions = getRecurringTransactions(dateInterval)
        
        var sum = recurringTransactions.reduce(0, { $0 + $1.amount })
        
        for transaction in transactions {
            if transaction.date > dateInterval.end {
                continue
            } else if transaction.date < dateInterval.start {
                break
            }

            sum += transaction.amount
        }
        
        return sum
    }
    
    /// Convert a time period to a context-aware label.
    private var timePeriodLabel: String {
        switch(period) {
        case .oneDay:
            return "today"
        case .oneWeek:
            return "this week"
        case .twoWeeks:
            return "this fortnight"
        case .oneMonth:
            return "this month"
        case .threeMonths:
            return "this quarter"
        case .oneYear:
            return "this year"
        }
    }
    
    /// A label with the total amount spent and the aggregation period.
    private var spendingSummary: String {
        "Spent \(Currency.format(totalSpending)) \(timePeriodLabel)"
    }
    
    var body: some View {
        Text(spendingSummary)
    }
}

struct BudgetOverview_Previews: PreviewProvider {
    static var data = DataModel()
    
    static var previews: some View {
        BudgetOverview(
            period: data.period,
            transactions: data.transactions,
            getRecurringTransactions: { dateInterval in data.getRecurringTransactions(for: dateInterval) }
        )
    }
}
