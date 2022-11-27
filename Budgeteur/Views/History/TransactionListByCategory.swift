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
    
    /// All the recorded transactions.
    @FetchRequest(sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)]) private var transactions: FetchedResults<Transaction>
    
    private var groupedTransactions: [(key: DateInterval, value: [TransactionWrapper])] {
        TransactionSet.fromTransactions(Array(transactions), groupBy: period)
            .groupAllByDateInterval(period: period)
    }
    
    var body: some View {
        List {
            ForEach(groupedTransactions, id: \.key) { dateInterval, groupedTransactions in
                TransactionGroupCategory(title: period.getDateIntervalLabel(for: dateInterval), transactions: groupedTransactions)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct TransactionListByCategory_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        TransactionListByCategory(period: .oneWeek)
            .environment(\.managedObjectContext, dataManager.context)
            .onAppear {
                dataManager.addSampleData()
            }
    }
}
