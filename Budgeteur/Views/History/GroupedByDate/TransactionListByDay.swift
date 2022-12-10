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
    ///
    var predicate: NSPredicate?
    
    /// All the recorded transactions.
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    @Environment(\.managedObjectContext) private var context
    
    init(period: Period, predicate: NSPredicate? = nil) {
        self.period = period
        self.predicate = predicate
        
        _transactions = FetchRequest<Transaction>(
            sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)],
            predicate: predicate
        )
    }
    
    private var groupedTransactions: [(key: DateInterval, value: TransactionSet)] {
        TransactionSet.fromTransactions(Array(transactions), groupBy: period)
            .groupByDateInterval(period: period)
    }
    
    private var startDate: Date {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]
        
        let transaction = try? context.fetch(request)
        
        return transaction?.first?.date ?? Date.now
    }
    
    var body: some View {
        ForEach(period.getDateIntervals(from: startDate), id: \.hashValue) { dateInterval in
            // TODO: Add transaction group which loads transactions internally
            Text(dateInterval.description)
        }
        
        ForEach(groupedTransactions, id: \.key) { dateInterval, groupedTransactionSet in
            TransactionGroup(title: period.getDateIntervalLabel(for: dateInterval), transactionSet: groupedTransactionSet, period: period)
        }
    }
}

struct TransactionListByDay_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        List {
            TransactionListByDay(period: .oneWeek)
        }
        .environment(\.managedObjectContext, dataManager.context)
        .onAppear {
            dataManager.addSampleData()
        }
    }
}
