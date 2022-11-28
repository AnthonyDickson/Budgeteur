//
//  TransactionGroupCategory.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Displays transactions grouped by time period and recurring transactions in their own section.
struct TransactionGroupCategory: View {
    /// The text that appears in the section header.
    var title: String
    /// The transactions to display.
    var transactions: [TransactionWrapper]
    
    private var sumExpenses: Double {
        transactions.filter { $0.type == .expense }.sum(\.amount)
    }
    
    private var sumIncome: Double {
        transactions.filter { $0.type == .income }.sum(\.amount)
    }
    
    /// Groups transactions by their category.
    /// - Parameter transactions: The transactions to group.
    /// - Returns: A list of 2-tuples which each contain the category and a list of the transactions that belong to that category.
    static func groupByCategory(_ transactions: [TransactionWrapper]) -> [(key: UserCategory?, value: [TransactionWrapper])] {
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.category })
        
        var categoryTotals: Dictionary<UserCategory?, Double> = [:]
        
        for (category, transactions) in groupedTransactions {
            categoryTotals[category] = transactions.sum(\.amount)
        }
        
        return groupedTransactions.sorted(by: { categoryTotals[$0.key]! > categoryTotals[$1.key]! })
    }
    
    var body: some View {
        // Cache these properties to avoid unnecessarily re-calculating them in the loop.
        let totalIncome = sumIncome
        let totalExpenses = sumExpenses
        
        Section {
            ForEach(Self.groupByCategory(transactions), id: \.key) { category, groupedTransactions in
                CollapsibleTransactionSection(
                    title: category?.name ?? UserCategory.defaultName,
                    transactions: groupedTransactions,
                    useDateForHeader: true,
                    totalIncome: totalIncome,
                    totalExpenses: totalExpenses
                )
            }
        } header: {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .label))
                Spacer()
                VStack {
                    Text(Currency.format(totalIncome))
                    Text(Currency.format(-totalExpenses))
                }
            }
        }
        
    }
}

struct TransactionGroupCategory_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        m.addSampleData()
        return m
    }()
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
        let (dateInterval, groupedTransactions) = TransactionSet.fromTransactions(transactions, groupBy: period)
            .groupAllByDateInterval(period: period)[0]
        let title = period.getDateIntervalLabel(for: dateInterval)
        
        List {
            TransactionGroupCategory(title: title, transactions: groupedTransactions)
        }
    }
}
