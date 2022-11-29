//
//  HistoryHeader.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI



/// Displays a title, a button for toggling how the transactions are grouped and a picker the time period grouping.
struct HistoryHeader: View {
    /// Whether to group transactions by date interval or category.
    @Binding var groupByCategory: Bool
    /// The selected date interval to group transactions by.
    @Binding var period: Period
    /// Controls which transactions as shown (all, recurring only or non-recurring only).
    @Binding var transactionFilter: TransactionFilter
    
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.largeTitle)
                
                Spacer()
                
                Picker("Transaction Filter", selection: $transactionFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { theFilter in
                        Text("View \(theFilter.rawValue)")
                    }
                }
                // This is needed to ensure each option is rendered on one line and prevents the parent view from changing height.
                .scaledToFill()
                
                Button {
                    groupByCategory.toggle()
                }
                label: {
                    Label("Group by", systemImage: groupByCategory ? "tag.fill" : "tag")
                        .labelStyle(.iconOnly)
                }
            }
            
            PeriodPicker(selectedPeriod: $period)
        }
    }
}

struct HistoryHeader_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: false) { $groupByCategory in
            Stateful(initialState: Period.oneWeek) { $period in
                Stateful(initialState: TransactionFilter.all) { $transactionFilter in
                    HistoryHeader(groupByCategory: $groupByCategory, period: $period, transactionFilter: $transactionFilter)
                }
            }
        }
    }
}
