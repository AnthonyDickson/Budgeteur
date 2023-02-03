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
    
    /// The total amount of all transactions in the current time period (e.g. this week, this month).
    private var netSpending: Double {
        let dateInterval = period.getDateInterval(for: .now)
        let transactionSet = TransactionSet.fromTransactions(Array(transactions), in: dateInterval, groupBy: period)
        
        return transactionSet.netSpending
    }
    
    /// A label with the total amount spent and the aggregation period.
    private var spendingSummary: String {
        let amount = netSpending
        let underOver = amount < 0 ? "over" : "under"

        return "\(Currency.format(abs(amount))) \(underOver) budget \(period.contextLabel)"
    }
    
    var body: some View {
        Text(spendingSummary)
    }
}

struct BudgetOverview_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = Transaction(insertInto: m.context, amount: 405, date: .now)
        _ = Transaction(insertInto: m.context, amount: 15, date: .distantPast, recurrencePeriod: .weekly)
        
        return m
    }()
    
    static var previews: some View {
        BudgetOverview(period: .oneWeek)
            .environment(\.managedObjectContext, dataManager.context)
    }
}
