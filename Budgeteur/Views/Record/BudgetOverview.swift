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
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "recurrencePeriod == %@", RecurrencePeriod.never.rawValue)) private var oneOffTransactions: FetchedResults<Transaction>
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "recurrencePeriod != %@", RecurrencePeriod.never.rawValue)) private var recurringTransactions: FetchedResults<Transaction>
    
    @Environment(\.managedObjectContext) private var context
    
    /// The user selected time period for aggregating transactions.
    @AppStorage("period") private var period: Period = .oneWeek
    
    /// Calculate the net income from the one-off transactions.
    /// - Parameter dateInterval: The date interval to sum over, transactions outside this interval will be ignored.
    /// - Returns: The net income from one-off transactions for the specified period.
    private func sumOneOffTransactions(in dateInterval: DateInterval) -> Double {
        oneOffTransactions.filter { dateInterval.contains($0.date) }
            .reduce(0.0) { $1.type == TransactionType.income.rawValue ? $0 + $1.amount : $0 - $1.amount }
    }
    
    /// Calculate the net income from the recurring transactions.
    /// - Parameter dateInterval: The date interval to sum over, transactions outside this interval will be ignored.
    /// - Returns: The net income from one-off transactions for the specified period.
    private func sumRecurringTransactions(in dateInterval: DateInterval) -> Double {
        recurringTransactions.filter {
            // Only consider recurring transactions that:
            // 1) start recurring before the period ends;
            // 2) has no end date or stop recurring after the period starts.
            // This avoids generating the proxy transactions for recurring transactions that have already ended or have not yet started.
            $0.date <= dateInterval.end && ($0.endDate == nil || $0.endDate! >= dateInterval.start)
        }
        .reduce(0.0) { partialResult, baseTransaction in
            partialResult + baseTransaction.getRecurringTransactions(groupBy: period)
                .filter{ dateInterval.contains($0.date) }
                .reduce(0.0) { $1.type == .income ? $0 + $1.amount : $0 - $1.amount }
        }
    }
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private var totalSpending: Double {
        let dateInterval = period.getDateInterval(for: Date.now)
        
        return sumOneOffTransactions(in: dateInterval) + sumRecurringTransactions(in: dateInterval)
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
        let amount = totalSpending
        let underOver = totalSpending < 0 ? "over" : "under"
        
        return "\(Currency.format(abs(amount))) \(underOver) budget \(timePeriodLabel)"
    }
    
    var body: some View {
        Text(spendingSummary)
    }
}

struct BudgetOverview_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = m.createTransaction(amount: 405, date: Date.now)
        _ = m.createTransaction(amount: 15/7, date: Date.distantPast, recurrencePeriod: .daily)
        
        return m
    }()
    
    static var previews: some View {
        BudgetOverview()
            .environment(\.managedObjectContext, dataManager.context)
    }
}
