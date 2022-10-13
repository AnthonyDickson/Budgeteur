//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Shows transctions grouped by a category in a collapsable view.
struct TransactionGroup: View {
    /// The category that the transactions belong to.
    var category: UserCategory?
    /// The transaction data.
    var transactions: [Transaction]
    /// What to do when a user taps on a transaction row.
    var onRowTap: (_ transaction: Transaction) -> ()
    /// What to do when a user deletes a transaction.
    var onRowDelete: (_ indexSet: IndexSet) -> ()
    
    /// Whether to display the individual transactions.
    @State private var showTransactions  = false
    
    /// A formatted string containing the sum of the transaction amounts.
    private var totalAmount: String {
        let total = transactions.reduce(0) { $0 + $1.amount}
        
        return Currency.format(total)
    }
    
    /// The category name, or a suitable default.
    private var categoryName: String {
        category?.name ?? UserCategory.defaultName
    }

    var body: some View {
        Section {
            // TODO: Animate the group being expanded with a sliding animation.
            if showTransactions {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction, displayCategory: false)
                        .padding(.leading)
                        .onTapGesture {
                            onRowTap(transaction)
                        }
                }
                .onDelete { indexSet in
                    onRowDelete(indexSet)
                }
            }
        } header: {
            HStack {
                Text("Spent \(totalAmount) on \(categoryName)")
                Spacer()
                Text("\(transactions.count) items")
                Label("Expand Grouped Transactions", systemImage: showTransactions ? "chevron.down" : "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .foregroundColor(.primary)
            .onTapGesture {
                withAnimation {
                    showTransactions.toggle()
                }
            }
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
            by: { getDateInterval(for: $0.date, period: data.period) }
        )
    }
    
    /// Find the calendar quarter for a date, and return the start of the quarter.
    /// - Parameter date: A date.
    /// - Returns: The date of the first day of the calendar quarter that the given date belongs to.
    private func getQuarterStart(for date: Date) throws -> Date {
        let calendar = Calendar.current
        // Months are one-indexed so we subtract one.
        let quarter = (calendar.component(.month, from: date) - 1) / 3
        let quarterStart = quarter * 3 + 1
        
        return calendar.date(from: DateComponents(
            year: calendar.component(.year, from: date),
            month: quarterStart
        ))!
    }
    
    /// Get the date interval for the user selected time period.
    /// - Parameter date: A date.
    /// - Parameter period: The time period the user has selected in the GUI.
    /// - Returns: A date interval corresponding to the date and selected time period.
    private func getDateInterval(for date: Date, period: Period) -> DateInterval {
        // Use ISO8601 calendar to ensure weeks start from monday
        let calendar = Calendar(identifier: .iso8601)
        var startDate: Date
        var endDate: Date
        
        switch(period) {
        case .oneDay:
            startDate = date
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        case .oneWeek:
            startDate = calendar.date(
                from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            )!
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        case .twoWeeks:
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            if day < 15 {
                startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
                endDate = calendar.date(from: DateComponents(year: year, month: month, day: 14))!
            } else {
                startDate = calendar.date(from: DateComponents(year: year, month: month, day: 15))!
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            }
        case .oneMonth:
            startDate = calendar.date(
                from: calendar.dateComponents([.year, .month], from: date)
            )!
            endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        case .threeMonths:
            startDate = try! getQuarterStart(for: date)
            endDate = calendar.date(byAdding: DateComponents(month: 3, day: -1), to: startDate)!
        case .oneYear:
            startDate = calendar.date(
                from: calendar.dateComponents([.year], from: date)
            )!
            endDate = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startDate)!
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
    
    /// Format a date for section headers.
    /// - Parameters:
    ///   - date: A date.
    ///   - withYear: Whether to include the year.
    /// - Returns: The formatted date string.
    private func formatDateForHeader(_ date: Date, withYear: Bool = false) -> String {
        let style = Date.FormatStyle.dateTime.day().month(.abbreviated)
        
        if withYear {
            return "\(date.formatted(style)) '\(date.formatted(.dateTime.year(.twoDigits)))"
        }
        
        return date.formatted(style)
    }
    
    /// Get a formatted string for a given date interval and user selected time period.
    /// - Parameters:
    ///   - dateInterval: A date interval.
    ///   - period: The time period the user has selected in the GUI.
    /// - Returns: A formatted string for the date interval.
    private func getDateLabel(for dateInterval: DateInterval, period: Period) -> String {
        switch(data.period) {
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
    
    /// Group transactions by category.
    /// - Parameter transactions: Transaction data.
    /// - Returns: An array of dictionary elements mapping categories to lists of transactions.
    private func groupTransactionsByCategory(_ transactions: [Transaction]) -> [Dictionary<UserCategory?, [Transaction]>.Element] {
        let result = Dictionary(grouping: transactions, by: { $0.category })
        let sortedResults = result.sorted(by: {
            ($0.key?.name ?? UserCategory.defaultName) < ($1.key?.name ?? UserCategory.defaultName)
        })

        return sortedResults
    }
    
    var body: some View {
        List {
            ForEach(transactionsByDate.sorted(by: { $0.key > $1.key}), id: \.key) { dateInterval, transactions in
                Section {
                    if data.groupByCategory {
                        ForEach(groupTransactionsByCategory(transactions), id: \.key) { category, subTransactions in
                            TransactionGroup(
                                category: category,
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
                            TransactionRow(transaction: transaction)
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
                        Text(getDateLabel(for: dateInterval, period: data.period))
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
