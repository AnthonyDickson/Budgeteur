//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

extension Period {
    /// Format a date for section headers.
    /// - Parameters:
    ///   - date: A date.
    ///   - withYear: Whether to include the year.
    /// - Returns: The formatted date string.
    fileprivate func formatDateForHeader(_ date: Date, withYear: Bool = false) -> String {
        let style = Date.FormatStyle.dateTime.day().month(.abbreviated)
        
        if withYear {
            return "\(date.formatted(style)) '\(date.formatted(.dateTime.year(.twoDigits)))"
        }
        
        return date.formatted(style)
    }
    
    /// Get a formatted string for a given date interval and user selected time period.
    /// - Parameters:
    ///   - dateInterval: A date interval.
    /// - Returns: A formatted string for the date interval.
    fileprivate func getDateLabel(for dateInterval: DateInterval) -> String {
        switch(self) {
        case .oneDay:
            return formatDateForHeader(dateInterval.start, withYear: true)
        case .oneWeek, .twoWeeks, .threeMonths:
            let start = formatDateForHeader(dateInterval.start)
            let end = formatDateForHeader(dateInterval.end, withYear: true)
            
            return "\(start) - \(end)"
        case .oneMonth:
            let month = dateInterval.start.formatted(.dateTime.month())
            let year = dateInterval.start.formatted(.dateTime.year(.twoDigits))
            
            return "\(month) '\(year)"
        case .oneYear:
            return dateInterval.start.formatted(.dateTime.year())
        }
    }
}


/// Displays the details of transactions in a vertical list.
struct TransactionList: View {
    /// The app's data model.
    @ObservedObject var data: DataModel
    
    @State private var isEditing = false
    @State private var selectedTransaction = Transaction.sample
    
    /// The transactions grouped by the user selected time period.
    private var transactionsByDate: Dictionary<DateInterval, [Transaction]> {
        Dictionary(
            grouping: data.transactions,
            by: { data.period.getDateInterval(for: $0.date) }
        )
    }
    
    /// Group transactions by category.
    /// - Parameter transactions: Transaction data.
    /// - Returns: An array of dictionary elements mapping category IDs to lists of transactions.
    private func groupTransactionsByCategory(_ transactions: [Transaction]) -> [Dictionary<UUID?, [Transaction]>.Element] {
        let result = Dictionary(grouping: transactions, by: { $0.categoryID })
        let sortedResults = result.sorted(by: {
            data.getCategoryName($0.key) < data.getCategoryName($1.key)
        })
        
        return sortedResults
    }
    
    var body: some View {
        List {
            ForEach(transactionsByDate.sorted(by: { $0.key > $1.key}), id: \.key) { dateInterval, transactions in
                Section {
                    if data.groupByCategory {
                        ForEach(groupTransactionsByCategory(transactions), id: \.key) { categoryID, subTransactions in
                            TransactionGroup(
                                categoryName: data.getCategoryName(categoryID),
                                transactions: subTransactions,
                                onRowTap: { transaction in
                                    selectedTransaction = transaction
                                    isEditing = true
                                },
                                onRowDelete: { indexSet in
                                    data.transactions.remove(atOffsets: indexSet)
                                }
                            )
                        }
                    } else {
                        ForEach(transactions) { transaction in
                            TransactionRow(
                                transaction: transaction,
                                categoryName: data.getCategoryName(transaction.categoryID)
                            )
                            .onTapGesture {
                                selectedTransaction = transaction
                                isEditing = true
                            }
                        }
                        .onDelete { indexSet in
                            data.transactions.remove(atOffsets: indexSet)
                        }
                    }
                } header: {
                    HStack {
                        Text("Spent \(Currency.format(transactions.reduce(0) { $0 + $1.amount}))")
                        Spacer()
                        Text(data.period.getDateLabel(for: dateInterval))
                    }
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    data.groupByCategory.toggle()
                } label: {
                    Label("Group by Category", systemImage: data.groupByCategory ? "tag.fill" : "tag")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                PeriodPicker(selectedPeriod: $data.period)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                TransactionEditor(categories: $data.categories,
                                  transaction: $selectedTransaction)
                // The navigation is defined here so we don't have to bind and pass in ``isEditing``.
                .navigationTitle("Edit Transaction")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button("Cancel", role: .cancel) {
                            isEditing = false
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            data.updateTransaction(selectedTransaction)
                            isEditing = false
                        }
                    }
                }
            }
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TransactionList(data: DataModel())
        }
    }
}
