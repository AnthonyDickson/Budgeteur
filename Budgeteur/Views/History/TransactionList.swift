//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/12/22.
//

import SwiftUI

/// A list of transactions, grouped by date interval and then day or category.
///
/// **Note:** This view should be wrapped in a `List` view.
struct TransactionList: View {
    /// The selected date interval to group transactions by.
    var period: Period
    /// Whether to group the transactions by category (`true`) or by date (`false`).
    var groupByCategory: Bool
    /// A `NSPredicate` to filter transactions by text search or transaction type.
    var predicate: NSPredicate?
    
    @Environment(\.managedObjectContext) private var context
    
    private var startDate: Date {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]
        
        let transaction = try? context.fetch(request)
        
        return transaction?.first?.date ?? Date.now
    }
    
    var body: some View {
        ForEach(period.getDateIntervals(from: startDate).reversed(), id: \.hashValue) { dateInterval in
            if groupByCategory {
                TransactionGroupCategory(dateInterval: dateInterval, period: period, predicate: predicate)
            } else {
                TransactionGroup(dateInterval: dateInterval, period: period, predicate: predicate)
            }
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        m.addSampleData(numSamples: 250)
        return m
    }()
    
    static var previews: some View {
        ForEach([true, false], id: \.self) { groupByCategory in
            List {
                TransactionList(period: .oneWeek, groupByCategory: groupByCategory)
            }
            .previewDisplayName("Grouped by " + (groupByCategory ? "Category" : "Date"))
        }
        .environment(\.managedObjectContext, dataManager.context)
    }
}
