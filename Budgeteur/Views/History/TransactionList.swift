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
    
    /// Controls how many transaction groups are shown in the infinite scrolling list.
    @State private var stopIndex = 1
    
    private var startDate: Date {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]
        
        let transaction = try? context.fetch(request)
        
        return transaction?.first?.date ?? Date.now
    }
    
    var body: some View {
        // TODO: Make `stopIndex` reset to 1 when the period is changed.
        let dateIntervals = Array(period.getDateIntervals(from: startDate).reversed())
        
        // TODO: Fix 'Non-constant range: argument must be an integer literal' warning.
        // TODO: Fix warning when changing period: "ForEach<Range<Int>, Int, Optional<ModifiedContent<Group<_ConditionalContent<TransactionGroupCategory, TransactionGroup>>, _AppearanceActionModifier>>> count (53) != its initial count (13). `ForEach(_:content:)` should only be used for *constant* data. Instead conform data to `Identifiable` or use `ForEach(_:id:content:)` and provide an explicit `id`!"
        ForEach(0..<dateIntervals.count) { index in
            if index < stopIndex && index < dateIntervals.count {
                let dateInterval = dateIntervals[index]

                Group {
                    if groupByCategory {
                        TransactionGroupCategory(dateInterval: dateInterval, period: period, predicate: predicate)
                    } else {
                        TransactionGroup(dateInterval: dateInterval, period: period, predicate: predicate)
                    }
                }
                .onAppear {
                    let nextIndex = stopIndex + 1
                    
                    if nextIndex < dateIntervals.count {
                        stopIndex = nextIndex
                    }
                }
            }
        }
        
        if stopIndex < dateIntervals.count {
            Button("Load More") {
                stopIndex += 1
            }
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([true, false], id: \.self) { groupByCategory in
            List {
                TransactionList(period: .oneWeek, groupByCategory: groupByCategory)
            }
            .previewDisplayName("Grouped by " + (groupByCategory ? "Category" : "Date"))
        }
        .environment(\.managedObjectContext, DataManager.preview.context)
    }
}
