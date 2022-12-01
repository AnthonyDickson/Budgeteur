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
    
    /// Text the user has typed into the search bar. Will be used to filter transactions by label or category name.
    @State private var searchText: String = ""
    /// Predicate for fetch request that filters transactions by recurrence period and/or label/category name.
    private var predicate: NSPredicate {
        transactionFilter.getPredicate(with: searchText)
    }
    
    var body: some View {
        VStack {
            HistoryHeader(groupByCategory: $groupByCategory, period: $period, transactionFilter: $transactionFilter)
                .padding(.horizontal)
            
            List {
                SearchBar(searchText: $searchText)
                
                if groupByCategory {
                    TransactionListByCategory(period: period, predicate: predicate)
                } else {
                    TransactionListByDay(period: period, predicate: predicate)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct History_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        History()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
            .environmentObject(dataManager)
            .onAppear {
                dataManager.addSampleData(numSamples: 500)
            }
    }
}
