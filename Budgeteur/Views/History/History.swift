//
//  History.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 5/11/22.
//

import SwiftUI

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
            
            if transaction.recurrencePeriod != .never {
                Label("Recurring Transaction", systemImage: "repeat")
                    .labelStyle(.iconOnly)
            }
            
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
    
    @State private var selectedTransaction: TransactionItem? = nil
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        // TODO: Enable sorting by either date or amount.
        ForEach(transactions.sorted(by: { $0.date > $1.date })) { transaction in
            TransactionRow(transaction: transaction, useDateForHeader: useDateForHeader)
                .onTapGesture {
                    selectedTransaction = transaction
                }
        }
        .onDelete { indexSet in
            DispatchQueue.main.async {
                for index in indexSet {
                    context.delete(transactions[index].parent)
                }
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            NavigationStack {
                TransactionEditor(transaction: transaction)
            }
        }

    }
}


/// Form for editing an existing transaction, or deleting it.
struct TransactionEditor: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @State var transaction: TransactionItem
    
    static private let numberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    private var isRecurringTransaction: Bool {
        transaction.parent.recurrencePeriod != RecurrencePeriod.never.rawValue
    }
    
    private var dateSectionLabel: String {
        isRecurringTransaction ? "Start Date" : "Date"
    }

    private func endOfDay(for date: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
    }
    
    
    var body: some View {
        List {
            Section("Description"){
                TextField("Description", text: $transaction.label, axis: .vertical)
            }
            
            Section("Tag") {
                CategoryPicker(selectedCategory: $transaction.category)
                    .padding(.horizontal, -20)
            }
            
            Section("Amount") {
                TextField("Amount", value: $transaction.amount, formatter: TransactionEditor.numberFormatter)
                    .keyboardType(.decimalPad)
            }
            
            
            Section(dateSectionLabel) {
                DatePicker(dateSectionLabel, selection: $transaction.date, displayedComponents: .date)
                    .labelsHidden()
            }
            
            if isRecurringTransaction {
                Section("End Date") {
                    DatePicker(
                        "End Date",
                        selection: Binding<Date>(
                            get: { transaction.endDate ?? Date.now },
                            set: { transaction.endDate = endOfDay(for: $0) }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
            
            Section("Repeats") {
                RecurrencePeriodPicker(
                    recurrencePeriod: $transaction.recurrencePeriod,
                    allowNever: !isRecurringTransaction
                )
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dataManager.updateTransaction(transaction: transaction)
                    dismiss()
                }
            }
        }
        .onAppear {
            if isRecurringTransaction {
                // Need to do this since TransactionItem for recurring transactions will have the amount adjusted for the current time period. The parent transaction holds the unadjusted amount.
                transaction.amount = transaction.parent.amount
                // Dates will also be for the proxy transaction, rather than the parent transaction.
                transaction.date = transaction.parent.date
                transaction.endDate = transaction.parent.endDate
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
                    title: category?.name ?? UserCategory.defaultName,
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

/// Displays transactions in a grouped list view with an area at the top for grouping controls.
struct History: View {
    @EnvironmentObject private var dataManager: DataManager
    /// All the recorded transactions.
    @FetchRequest(sortDescriptors: [SortDescriptor(\Transaction.date, order: .reverse)]) private var transactions: FetchedResults<Transaction>
    /// Whether to group transactions by date interval or category.
    @AppStorage("groupByCategory") private var groupByCategory: Bool = false
    /// The selected date interval to group transactions by.
    @AppStorage("period") private var period: Period = .oneWeek
    
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
                recurringTransactions.append(contentsOf: transaction.getRecurringTransactions(with: period))
            }
        }
        
        return TransactionSet(oneOffTransactions: oneOffTransactions, recurringTransactions: recurringTransactions)
    }
    

    
    var body: some View {
        let transactionSet = processTransactions(transactions)
        
        VStack {
            HistoryHeader(groupByCategory: $groupByCategory, period: $period)
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
