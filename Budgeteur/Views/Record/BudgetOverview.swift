//
//  BudgetOverview.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI

struct BudgetOverview: View {
    @Environment(\.managedObjectContext) private var context
    
    /// The user selected time period for aggregating transactions.
    @AppStorage("period") private var period: Period = .oneWeek
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private var totalSpending: Double {
        let dateInterval = period.getDateInterval(for: Date.now)
        
        let requestForOneOffTransactions = Transaction.fetchRequest()
        requestForOneOffTransactions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%@ <= date AND date <= %@", dateInterval.start as NSDate, dateInterval.end as NSDate),
            NSPredicate(format: "recurrencePeriod == %@", RecurrencePeriod.never.rawValue)
        ])
        
        let requestForRecurringTransactions = Transaction.fetchRequest()
        requestForRecurringTransactions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "recurrencePeriod != %@", RecurrencePeriod.never.rawValue),
            NSPredicate(format: "date <= %@", dateInterval.end as NSDate),
            NSPredicate(format: "endDate = nil OR %@ <= endDate", dateInterval.start as NSDate)
        ])
        
        
        do {
            let oneOffTransactions = try context.fetch(requestForOneOffTransactions)
            let recurringTransactions = try context.fetch(requestForRecurringTransactions)
            
            let sum = oneOffTransactions.reduce(0.0) { partialResult, transaction in
                partialResult + transaction.amount
            } + recurringTransactions.reduce(0.0, { partialResult, transaction in
                partialResult + transaction.sumRecurringTransactions(in: dateInterval, groupBy: period)
            })
            
            return sum
        } catch {
            fatalError("Error fetching transactions: \(error.localizedDescription)")
        }
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
