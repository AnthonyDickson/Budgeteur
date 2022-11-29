//
//  History.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//

import SwiftUI

/// Displays transactions in a grouped list view with an area at the top for grouping controls.
struct History: View {
    /// Whether to group transactions by date interval or category.
    @AppStorage("groupByCategory") private var groupByCategory: Bool = false
    /// The selected date interval to group transactions by.
    @AppStorage("period") private var period: Period = .oneWeek
    /// Controls which transactions as shown (all, recurring only or non-recurring only).
    @AppStorage("transactionFilter") private var transactionFilter: TransactionFilter = .all
    
    var body: some View {
        VStack {
            HistoryHeader(groupByCategory: $groupByCategory, period: $period, transactionFilter: $transactionFilter)
                .padding(.horizontal)
            
            // TODO: Add search for transactions. Create predicate in `History` view?
            if groupByCategory {
                TransactionListByCategory(period: period, transactionFilter: transactionFilter)
            } else {
                TransactionListByDay(period: period, transactionFilter: transactionFilter)
            }
        }
    }
}

struct History_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        NavigationStack {
            History()
        }
        .environment(\.managedObjectContext, dataManager.container.viewContext)
        .environmentObject(dataManager)
        .onAppear {
            dataManager.addSampleData()
        }
    }
}
