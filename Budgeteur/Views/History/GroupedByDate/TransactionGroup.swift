//
//  TransactionGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

// TODO: Refactor out common code between ``TransactionGroup`` and ``TransactionGroupCategory``. Use protocol to hold common functionality?

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroup: View {
    /// The text that appears in the section header.
    private var title: String
    /// Only transactions within this date range are fetched.
    var dateInterval: DateInterval
    /// The time interval to group transactions into (e.g., 1 day, 1 week).
    var period: Period
    
    /// All the transactions for the specified date interval.
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    @Environment(\.managedObjectContext) private var context
    
    init(dateInterval: DateInterval, period: Period, predicate: NSPredicate? = nil) {
        self.title = period.getDateIntervalLabel(for: dateInterval)
        self.dateInterval = dateInterval
        self.period = period

        var compoundPredicate = Transaction.getPredicateForAllTransactions(in: dateInterval)
        
        if let predicate = predicate {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, predicate])
        }
        
        _transactions = FetchRequest<Transaction>(
            sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)],
            predicate: compoundPredicate
        )
    }
    
    var body: some View {
        let transactionSet = TransactionSet.fromTransactions(Array(transactions), in: dateInterval, groupBy: period)
        
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
    static var previews: some View {
        ForEach([Period.oneWeek, Period.oneDay], id: \.self) { period in
            let dateInterval = period.getDateInterval(for: .now)
            
            List {
                TransactionGroup(dateInterval: dateInterval, period: period)
            }
            .previewDisplayName(period.rawValue)
        }
        .environment(\.managedObjectContext, DataManager.preview.context)
    }
}
