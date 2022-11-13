//
//  TransactionView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//

import SwiftUI

/// Proxy object to display ``Transaction`` instances in the GUI. It can hold one-off transactions and the auto-generated recurring transactions.
struct TransactionItem: Identifiable {
    /// A unique identifier for the transaction, or the auto-generated recurring transaction.
    let id: UUID
    /// How much money was spent/earned.
    let amount: Double
    /// A description of the cash flow.
    let label: String
    /// When the transaction ocurred.
    let date: Date
    /// How often the transaction repeats, if ever.
    let recurrencePeriod: RecurrencePeriod
    /// The category that the transaction fits into (e.g., home expenses vs. entertainment).
    let category: UserCategory?
    /// The transaction that the proxy transaction was created from.
    let parent: Transaction
}

/// A collection of a list of one-off and recurring transactions.
struct TransactionSet {
    /// A list of the transactions that happen once.
    let oneOffTransactions: [TransactionItem]
    /// A list of the transactions that happen regularly.
    let recurringTransactions: [TransactionItem]
    
    /// The sum of the one-off transaction amounts.
    var sumOneOff: Double {
        oneOffTransactions.reduce(0) { partialResult, transaction in partialResult + transaction.amount }
    }
    
    /// The sum of the recurring transaction amounts.
    var sumRecurring: Double {
        recurringTransactions.reduce(0) { partialResult, transaction in partialResult + transaction.amount }
    }
    
    /// The sum of all transactions in the set.
    var sumAll: Double {
        sumOneOff + sumRecurring
    }
    
    /// Groups all of the one-off transactions by date (day).
    /// - Returns: A list of 2-tuples each containing the date and the list of transactions that occured on that day.
    func groupOneOffByDate() -> [(key: Date, value: [TransactionItem])] {
        return Dictionary(
            grouping: oneOffTransactions,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
        .sorted(by: { $0.key > $1.key })
    }
    
    /// Groups all transactions into date intervals based on the given period.
    /// - Parameter period: The time interval to group transactions into (e.g., 1 day, 1 week).
    /// - Returns: A list of 2-tuples that each contain the date interval and the list of transactions that occur within that interval.
    func groupAllByDateInterval(period: Period) -> [(key: DateInterval, value: [TransactionItem])] {
        return Dictionary(
            grouping: oneOffTransactions + recurringTransactions,
            by: { period.getDateInterval(for: $0.date) }
        )
        .sorted(by: { $0.key > $1.key })
    }
    
    
    /// Group transactions into date intervals while keeping the distinction between one-off and recurring transactions.
    /// - Parameter period: The time interval to group transactions into (e.g., 1 day, 1 week).
    /// - Returns: A list of 2-tuples that each contain the date interval and the set of transactions that occur within that interval.
    func groupByDateInterval(period: Period) -> [(key: DateInterval, value: TransactionSet)] {
        let oneOffTransactions = Dictionary(
            grouping: self.oneOffTransactions,
            by: { period.getDateInterval(for: $0.date) }
        )
        
        let recurringTransactions = Dictionary(
            grouping: self.recurringTransactions,
            by: { period.getDateInterval(for: $0.date) }
        )
        
        var result: Dictionary<DateInterval, TransactionSet> = [:]
        
        for (dateInterval, transactionsToAdd) in oneOffTransactions {
            if let transactions = result[dateInterval] {
                result[dateInterval] = TransactionSet(
                    oneOffTransactions: transactions.oneOffTransactions + transactionsToAdd,
                    recurringTransactions: transactions.recurringTransactions
                )
            } else {
                result[dateInterval] = TransactionSet(oneOffTransactions: transactionsToAdd, recurringTransactions: [])
            }
        }
        
        for (dateInterval, transactionsToAdd) in recurringTransactions {
            if let transactions = result[dateInterval] {
                result[dateInterval] = TransactionSet(
                    oneOffTransactions: transactions.oneOffTransactions,
                    recurringTransactions: transactions.recurringTransactions + transactionsToAdd
                )
            } else {
                result[dateInterval] = TransactionSet(oneOffTransactions: [], recurringTransactions: transactionsToAdd)
            }
        }
        
        return result
            .sorted(by: { $0.key > $1.key })
    }
}

/// Convert a date into a formatted string containing the short month and two digit day
/// - Parameter date: The date to format.
/// - Returns: A string of the date.
fileprivate func getFormattedDate(for date: Date) -> String {
    date.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
}

/// Get the total amount for a list of transactions.
/// - Parameter transactions: The transactions to sum.
/// - Returns: The sum of the transactions.
fileprivate func getTotal(of transactions: [TransactionItem]) -> Double {
    return transactions.reduce(0) { partialResult, transaction in
        partialResult + transaction.amount
    }
}

/// Displays a transaction in a horizontal layout. Intended to used within a list.
struct TransactionRow: View {
    /// The transaction to display.
    var transaction: TransactionItem
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool = false
    
    var body: some View {
        HStack {
            if useDateForHeader {
                VStack(alignment: .leading) {
                    Text(getFormattedDate(for: transaction.date))
                    Text(transaction.label)
                        .font(.caption)
                }
            } else if let categoryName = transaction.category?.name {
                VStack(alignment: .leading) {
                    Text(categoryName)
                    Text(transaction.label)
                        .font(.caption)
                }
            } else {
                Text(transaction.label)
            }
            Spacer()
            Text(Currency.format(transaction.amount))
        }
    }
}

/// Creates a ForEach displaying each transaction as a ``TransactionRow``.
struct TransactionRows: View {
    /// The collection of transactions to display in this section.
    var transactions: [TransactionItem]
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        ForEach(transactions.sorted(by: { $0.date > $1.date })) { transaction in
            TransactionRow(transaction: transaction, useDateForHeader: useDateForHeader)
        }
        .onDelete { indexSet in
            DispatchQueue.main.async {
                for index in indexSet {
                    context.delete(transactions[index].parent)
                }
            }
        }
    }
}

/// A section that the user can collapse/expand by tapping on the header.
struct CollapsibleTransactionSection: View {
    /// The string to display in the section header
    var title: String
    /// The collection of transactions to display in this section.
    var transactions: [TransactionItem]
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool
    /// Whether to expand the transactions list. Defaults to having the list collapsed (false).
    @State var showTransactions = false
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        Section {
            if showTransactions {
                TransactionRows(transactions: transactions, useDateForHeader: useDateForHeader)
                    .padding(.leading, 20)
            }
        } header: {
            HStack {
                Text(title)
                Spacer()
                Text(Currency.format(getTotal(of: transactions)))
                    .bold(showTransactions)
                
                Label("Expand Grouped Transactions", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .rotationEffect(showTransactions ? Angle(degrees: 90) : Angle(degrees: 0))
                    .animation(.easeInOut.speed(2), value: showTransactions)
            }
            .onTapGesture {
                withAnimation {
                    showTransactions.toggle()
                }
            }
        }
    }
}

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroup: View {
    /// The text that appears in the section header.
    var title: String
    /// The set of one-off and recurring transactions to display.
    var transactionSet: TransactionSet
    /// The time interval to group transactions into (e.g., 1 day, 1 week).
    var period: Period
    
    var body: some View {
        Section {
            ForEach(transactionSet.groupOneOffByDate(), id: \.key) { date, transactions in
                if period == .oneDay {
                    TransactionRows(transactions: transactions, useDateForHeader: false)
                } else {
                    CollapsibleTransactionSection(
                        title: getFormattedDate(for: date),
                        transactions: transactions,
                        useDateForHeader: false,
                        showTransactions: true
                    )
                }
            }
            
            if transactionSet.recurringTransactions.count > 0 {
                CollapsibleTransactionSection(
                    title: "Recurring Transactions",
                    transactions: transactionSet.recurringTransactions,
                    useDateForHeader: false
                )
            }
        } header: {
            HStack {
                Text(title)
                Spacer()
                Text(Currency.format(transactionSet.sumAll))
            }
        }
        
    }
}

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroupCategory: View {
    /// The text that appears in the section header.
    var title: String
    /// The transactions to display.
    var transactions: [TransactionItem]
    
    /// Groups transactions by their category.
    /// - Parameter transactions: The transactions to group.
    /// - Returns: A list of 2-tuples which each contain the category and a list of the transactions that belong to that category.
    func groupByCategory(_ transactions: [TransactionItem]) -> [(key: UserCategory?, value: [TransactionItem])] {
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.category })
        
        var categoryTotals: Dictionary<UserCategory?, Double> = [:]
        
        for (category, transactions) in groupedTransactions {
            categoryTotals[category] = transactions.reduce(0, { $0 + $1.amount })
        }
        
        return groupedTransactions.sorted(by: { categoryTotals[$0.key]! > categoryTotals[$1.key]! })
    }
    
    var body: some View {
        Section {
            ForEach(groupByCategory(transactions), id: \.key) { category, groupedTransactions in
                CollapsibleTransactionSection(
                    title: category?.name ?? UserCategoryClass.defaultName,
                    transactions: groupedTransactions,
                    useDateForHeader: true
                )
            }
        } header: {
            HStack {
                Text(title)
                Spacer()
                Text(Currency.format(getTotal(of: transactions)))
            }
        }
        
    }
}

/// Displays a header, a button for toggling how the transactions are grouped and a picker the time period grouping.
struct TransactionListHeader: View {
    /// Whether to group transactions by date interval or category.
    @Binding var groupByCategory: Bool
    /// The selected date interval to group transactions by.
    @Binding var period: Period
    
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.largeTitle)
                
                Spacer()
                
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

/// Displays transactions in a grouped list view with an area at the top for grouping controls.
struct TransactionList: View {
    /// All the recorded transactions.
    @FetchRequest(sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)]) var transactions: FetchedResults<Transaction>
    /// Whether to group transactions by date interval or category.
    @State var groupByCategory: Bool = false
    /// The selected date interval to group transactions by.
    @State var period: Period = .oneWeek
    
    /// Convert transactions from the Core Data interface class to a proxy class object that is more suited for the GUI.
    /// - Parameter transactions: The transactions from the Core Data store.
    /// - Returns: The transactions as a set of one-off transactions and auto-generated recurring transactions.
    func processTransactions(_ transactions: FetchedResults<Transaction>) -> TransactionSet {
        var oneOffTransactions: [TransactionItem] = []
        var recurringTransactions: [TransactionItem] = []
        
        for transaction in transactions {
            if transaction.recurrencePeriod == RecurrencePeriod.never.rawValue {
                oneOffTransactions.append(TransactionItem(
                    id: transaction.id,
                    amount: transaction.amount,
                    label: transaction.label,
                    date: transaction.date,
                    recurrencePeriod: .never,
                    category: transaction.category,
                    parent: transaction
                ))
            } else {
                recurringTransactions.append(contentsOf: getRecurringTransactions(for: transaction))
            }
        }
        
        return TransactionSet(oneOffTransactions: oneOffTransactions, recurringTransactions: recurringTransactions)
    }
    
    /// Generate proxy transaction objects for a given base transaction.
    /// - Parameter transaction: The base transaction to generate recurring transactions from.
    /// - Returns: The list of generated transactions.
    func getRecurringTransactions(for transaction: Transaction) -> [TransactionItem] {
        var recurringTransactions: [TransactionItem] = []
        
        let startDate =  Calendar.current.startOfDay(for: transaction.date)
        let today = Calendar.current.startOfDay(for: Date.now)
        
        guard let endDate = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: today) else {
            fatalError("Error: Could create date by adding \(DateComponents(day: 1, second: -1)) to \(Date.now)")
        }
        
        guard let recurrencePeriod = RecurrencePeriod(rawValue: transaction.recurrencePeriod) else {
            fatalError("Error: Could not convert '\(transaction.recurrencePeriod)' to a valid enum value of RecurrencePeriod.")
        }
        
        var multiplier: Double
        
        switch recurrencePeriod {
        case RecurrencePeriod.daily:
            multiplier = 1.0
        case RecurrencePeriod.weekly:
            multiplier = 52.1785/365.25
        case RecurrencePeriod.fortnighly:
            multiplier = 26.0892/365.25
        case RecurrencePeriod.monthly:
            multiplier = 12/365.25
        case RecurrencePeriod.quarterly:
            multiplier = 3/365.25
        case RecurrencePeriod.yearly:
            multiplier = 1/365.25
        default:
            fatalError("Given non-recurring transaction (recurrencePeriod == .never) when a recurring transaction was expected.")
        }
        
        let dateIncrement = period.getDateIncrement()
        
        var date = startDate
        
        let isoCalendar = Calendar(identifier: .iso8601)
        
        while date < endDate {
            let dailyAmount = transaction.amount * multiplier
            
            guard let nextDate = isoCalendar.date(byAdding: dateIncrement, to: date) else {
                fatalError("Error: Could not increment date \(date) by increment \(dateIncrement)")
            }
            
            // The date intervals are closed intervals, but the .day component returns the length of the open interval so we need to add one to the result.
            let numDays = Calendar.current.dateComponents([.day], from: date, to: nextDate).day! + 1
            let amountForPeriod = dailyAmount * Double(numDays)
            
            recurringTransactions.append(TransactionItem(
                id: UUID(),
                amount: amountForPeriod,
                label: transaction.label,
                date: date,
                recurrencePeriod: recurrencePeriod,
                category: transaction.category,
                parent: transaction
            ))
            
            date = nextDate
        }
        
        return recurringTransactions
    }
    
    var body: some View {
        let transactionSet = processTransactions(transactions)
        
        VStack {
            TransactionListHeader(groupByCategory: $groupByCategory, period: $period)
            .padding(.horizontal)
            
            List {
                if groupByCategory {
                    ForEach(transactionSet.groupAllByDateInterval(period: period), id: \.key) { dateInterval, groupedTransactions in
                        TransactionGroupCategory(title: period.getDateIntervalLabel(for: dateInterval), transactions: groupedTransactions)
                    }
                } else {
                    ForEach(transactionSet.groupByDateInterval(period: period), id: \.key) { dateInterval, groupedTransactionSet in
                        TransactionGroup(title: period.getDateIntervalLabel(for: dateInterval), transactionSet: groupedTransactionSet, period: period)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var dataManager: DataManager = .sample
    
    static var previews: some View {
        TransactionList()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
    }
}
