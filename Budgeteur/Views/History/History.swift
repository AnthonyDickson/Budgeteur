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
        // TODO: Add pagination (infinite scrolling). Start by loading the current year's transactions (and maybe the previous year's ones too?), then when the using reaches the bottom load in the next year's data. This will help reduce the length of hangs when opening the history view when there are many transactions in the CoreData store (e.g., 5K+).
        VStack {
            HistoryHeader(groupByCategory: $groupByCategory, period: $period, transactionFilter: $transactionFilter)
                .padding(.horizontal)
            
            List {
                SearchBar(searchText: $searchText)
                
                TransactionList(period: period, groupByCategory: groupByCategory, predicate: predicate)
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct History_Previews: PreviewProvider {
    static var previews: some View {
        History()
            .environment(\.managedObjectContext, DataManager.preview.context)
            .environmentObject(DataManager.preview)
    }
}
