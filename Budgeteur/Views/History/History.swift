//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// Displays the details of transactions in a vertical list.
struct History: View {
    /// The app's data model.
    @ObservedObject var data: DataModel
    
    /// Whether the transaction editor sheet is displayed.
    @State private var isEditing = false
    /// The transaction the user tapped on.
    @State private var selectedTransaction = TransactionClass.sample
    /// Whether to group transactions by category.
    @State private var groupByCategory: Bool = false
    
    /// The transactions grouped by the user selected time period.
    private var transactionsByDate: Dictionary<DateInterval, [TransactionClass]> {
        Dictionary(
            grouping: data.oneOffTransactions,
            by: { data.period.getDateInterval(for: $0.date) }
        )
    }
    
    /// Group transactions by category.
    /// - Parameter transactions: Transaction data.
    /// - Returns: An array of dictionary elements mapping category IDs to lists of transactions.
    private func groupTransactionsByCategory(_ transactions: [TransactionClass]) -> [Dictionary<UUID?, [TransactionClass]>.Element] {
        let result = Dictionary(grouping: transactions, by: { $0.categoryID })
        let sortedResults = result.sorted(by: {
            $0.value.reduce(0, { $0 + $1.amount}) > $1.value.reduce(0, { $0 + $1.amount})
        })
        
        return sortedResults
    }
    
    var body: some View {
        List {
            ForEach(transactionsByDate.sorted(by: { $0.key > $1.key}), id: \.key) { dateInterval, transactions in
                Section {
                    if groupByCategory {
                        // TODO: Insert recurring transactions for period into transaction groups
                        // TODO: For each group, add text displaying what percent of total spending/income the group contributes.
                        ForEach(groupTransactionsByCategory(transactions), id: \.key) { categoryID, subTransactions in
                            TransactionGroupOld(
                                categoryName: data.getCategoryName(categoryID),
                                transactions: subTransactions,
                                // TODO: For recurring transactions, the ``onRowTap`` callback in ``TransactionGroup`` should find and send the parent transaction.
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
                            TransactionRowOld(
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
                    
                    if let recurringTransactions = data.getRecurringTransactions(for: dateInterval), recurringTransactions.count > 0 {
                        // TODO: If ``groupByCategory`` is `true`, insert the repeated transactions into their respective categories.
                        RecurringTransactionGroup(
                            transactions: recurringTransactions,
                            getCategoryName: data.getCategoryName,
                            onRowTap: { recurringTransaction in
                                if let transaction = data.getTransaction(by: recurringTransaction.parentID) {
                                    selectedTransaction = transaction
                                    isEditing = true
                                }
                            }, onRowDelete: { indexSet in
                                // TODO: Show a confirmation dialog when deleting recurring transaction.
                                data.removeRecurringTransactions(atOffsets: indexSet, from: recurringTransactions)
                            })
                    }
                } header: {
                    HistorySectionHeader(transactions: transactions,
                                         recurringTransactions: data.getRecurringTransactions(for: dateInterval),
                                         dateIntervalLabel: data.period.getDateIntervalLabel(for: dateInterval))
                }
                .sheet(isPresented: $isEditing) {
                    NavigationStack {
                        TransactionEditorOld(
                            categories: $data.categories,
                            transaction: $selectedTransaction,
                            onCancel: {
                                isEditing = false
                            },
                            onSave: {
                                isEditing = false
                                data.updateTransaction(selectedTransaction)
                            },
                            // TODO: Only show the 'Stop Recurring' button if the transaction was set to recurr BEFORE the edit view is opened.
                            stopRecurring: { transaction in
                                isEditing = false
                                DispatchQueue.main.async {
                                    // For some reason, wrapping this function call gets rid of the warning (? not sure, has purple symbol instead of yellow) 'Publishing changes from within view updates is not allowed, this will cause undefined behavior.'
                                    data.stopRecurring(transaction: transaction)
                                }
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    groupByCategory.toggle()
                } label: {
                    Label("Group by Category", systemImage: groupByCategory ? "tag.fill" : "tag")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                PeriodPicker(selectedPeriod: $data.period)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}

struct History_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            History(data: DataModel())
        }
    }
}
