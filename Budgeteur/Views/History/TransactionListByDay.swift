//
//  TransactionListByDay.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI


/// A list of transactions, grouped by date interval and then day.
struct TransactionListByDay: View {
    /// The selected date interval to group transactions by.
    var period: Period
    
    /// All the recorded transactions.
    @FetchRequest(sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)]) private var transactions: FetchedResults<Transaction>
    
    private var groupedTransactions: [(key: DateInterval, value: TransactionSet)] {
        TransactionSet.fromTransactions(Array(transactions), groupBy: period)
            .groupByDateInterval(period: period)
    }
    
    var body: some View {
        // TODO: Can we improve performance on large datasets by getting the date intervals by only fetching the earliest transaction, and then fetch the transactions from within each `TransactionGroup`?
        List {
            ForEach(groupedTransactions, id: \.key) { dateInterval, groupedTransactionSet in
                TransactionGroup(title: period.getDateIntervalLabel(for: dateInterval), transactionSet: groupedTransactionSet, period: period)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct TransactionListByDay_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        TransactionListByDay(period: .oneWeek)
            .environment(\.managedObjectContext, dataManager.context)
            .onAppear {
                dataManager.addSampleData()
            }
    }
}
