//
//  TransactionGroupCategory.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroupCategory: View {
    /// Only transactions within this date range are fetched.
    var dateInterval: DateInterval
    /// The time interval to group transactions into (e.g., 1 day, 1 week).
    var period: Period
    
    /// The text that appears in the section header.
    private var title: String {
        period.getDateIntervalLabel(for: dateInterval)
    }
    
    /// All the transactions for the specified date interval.
    @FetchRequest private var transactions: FetchedResults<Transaction>
    
    @Environment(\.managedObjectContext) private var context
    
    init(dateInterval: DateInterval, period: Period, predicate: NSPredicate? = nil) {
        self.dateInterval = dateInterval
        self.period = period

        var compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "recurrencePeriod == %@ AND date BETWEEN {%@, %@}", RecurrencePeriod.never.rawValue, dateInterval.start as NSDate, dateInterval.end as NSDate),
            NSPredicate(format: "recurrencePeriod != %@ AND (date <= %@ AND (endDate == nil OR endDate >= %@))", RecurrencePeriod.never.rawValue, dateInterval.end as NSDate, dateInterval.start as NSDate)
        ])
        
        if let predicate = predicate {
            compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [compoundPredicate, predicate])
        }
        
        _transactions = FetchRequest<Transaction>(
            sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)],
            predicate: compoundPredicate
        )
    }
    
    func groupAndSort(transactionSet: TransactionSet) -> [Dictionary<String?, [TransactionWrapper]>.Element] {
        let transactions = transactionSet.all

        let sortedTransactions = transactions.sorted(by: { $1.date > $0.date })

        let groupedTransactons = Dictionary(grouping: sortedTransactions, by: { $0.category?.name })

        let sortedGroupedTransactions = groupedTransactons.sorted(by: { $0.value.sum(\.amount) > $1.value.sum(\.amount) })
        
        return sortedGroupedTransactions
    }
    
    var body: some View {
        // Cache these properties to avoid unnecessarily re-calculating them in the loop.
        let transactionSet = TransactionSet
            .fromTransactions(Array(transactions), in: dateInterval, groupBy: period)
        let totalIncome = transactionSet.sumIncome
        let totalExpenses = transactionSet.sumExpenses
        let transactionsByCategory = groupAndSort(transactionSet: transactionSet)

        Section {
            VStack {
                TransactionGroupHeader(title: title, totalIncome: totalIncome, totalExpenses: totalExpenses)
                
                Divider()
            }
            
            ForEach(transactionsByCategory, id: \.key) { categoryName, groupedTransactions in
                CollapsibleTransactionSection(
                    title: categoryName ?? UserCategory.defaultName,
                    transactions: groupedTransactions,
                    useDateForHeader: true,
                    totalIncome: totalIncome,
                    totalExpenses: totalExpenses
                )
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct TransactionGroupCategory_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        m.addSampleData(numSamples: 250)
        return m
    }()
    
    static var previews: some View {
        let period: Period = .oneWeek
        let dateInterval = period.getDateInterval(for: .now)
        
        List {
            TransactionGroupCategory(dateInterval: dateInterval, period: period)
        }
        .environment(\.managedObjectContext, dataManager.context)
        
    }
}
