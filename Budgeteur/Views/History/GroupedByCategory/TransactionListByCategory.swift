//
//  TransactionListByCategory.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// A list of transactions, grouped by date interval and then category.
struct TransactionListByCategory: View {
    /// The selected date interval to group transactions by.
    var period: Period
    /// Predicate for fetch request that filters transactions by recurrence period and/or label.
    var predicate: NSPredicate?
    
    /// All the recorded transactions.
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    init(period: Period, predicate: NSPredicate? = nil) {
        self.period = period
        self.predicate = predicate
        
        _transactions = FetchRequest<Transaction>(
            sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)],
            predicate: predicate
        )
    }
    
    private var groupedTransactions: [(key: DateInterval, value: [TransactionWrapper])] {
        TransactionSet.fromTransactions(Array(transactions), groupBy: period)
            .groupAllByDateInterval(period: period)
    }
    
    var body: some View {
        // TODO: Can we improve performance on large datasets by getting the date intervals by only fetching the earliest transaction, and then fetch the transactions from within each `TransactionGroupCategory`?
        ForEach(groupedTransactions, id: \.key) { dateInterval, groupedTransactions in
            TransactionGroupCategory(title: period.getDateIntervalLabel(for: dateInterval), transactions: groupedTransactions)
        }
    }
}

struct TransactionListByCategory_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        List {
            TransactionListByCategory(period: .oneWeek)
        }
        .environment(\.managedObjectContext, dataManager.context)
        .onAppear {
            dataManager.addSampleData()
        }
    }
}
