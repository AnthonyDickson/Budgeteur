//
//  BudgetOverview.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI
import CoreData

/// Display how much over/under budget the user is for the current period (e.g., this week).
struct BudgetOverview: View {
    /// The user selected time period for aggregating transactions.
    var period: Period
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    init(period: Period) {
        self.period = period
        
        let dateInterval = period.getDateInterval(for: .now)

        self._transactions = FetchRequest<Transaction>(
            sortDescriptors: [],
            predicate: Transaction.getPredicateForAllTransactions(in: dateInterval)
        )
    }
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private func getTotalSpending() -> Double {
        let dateInterval = period.getDateInterval(for: .now)
        let transactionSet = TransactionSet.fromTransactions(Array(transactions), in: dateInterval, groupBy: period)
        
        return transactionSet.all
            .reduce(0.0) { $1.type == .income ? $0 + $1.amount * (1 - $1.savings) : $0 - $1.amount }
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
        let amount = getTotalSpending()
        let underOver = amount < 0 ? "over" : "under"

        return "\(Currency.format(abs(amount))) \(underOver) budget \(timePeriodLabel)"
    }
    
    var body: some View {
        Text(spendingSummary)
    }
}

struct BudgetOverview_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = m.createTransaction(amount: 405, date: .now)
        _ = m.createTransaction(amount: 15, date: .distantPast, recurrencePeriod: .weekly)
        
        return m
    }()
    
    static var previews: some View {
        BudgetOverview(period: .oneWeek)
            .environment(\.managedObjectContext, dataManager.context)
    }
}
