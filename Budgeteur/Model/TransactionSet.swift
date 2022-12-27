//
//  TransactionSet.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import Foundation

/// A collection of a list of one-off and recurring transactions.
struct TransactionSet {
    /// A list of the transactions that happen once.
    let oneOffTransactions: [TransactionWrapper]
    /// A list of the transactions that happen regularly.
    let recurringTransactions: [TransactionWrapper]
    
    /// All of the one-off and recurring transactions in the set.
    var all: [TransactionWrapper] {
        oneOffTransactions + recurringTransactions
    }
    
    /// The sum of all transactions in the set.
    var sumAll: Double {
        oneOffTransactions.sum(\.amount) + recurringTransactions.sum(\.amount)
    }
    
    var sumExpenses: Double {
        sum(type: .expense)
    }
    
    var sumIncome: Double {
        sum(type: .income)
    }
    
    private func sum(type: TransactionType) -> Double {
        oneOffTransactions.filter({ $0.type == type }).sum(\.amount) + recurringTransactions.filter({ $0.type == type }).sum(\.amount)
    }
    
    /// Groups all of the one-off transactions by date (day).
    /// - Returns: A list of 2-tuples each containing the date and the list of transactions that occured on that day.
    func groupOneOffByDate() -> [(key: Date, value: [TransactionWrapper])] {
        return Dictionary(
            grouping: oneOffTransactions,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
        .sorted(by: { $0.key > $1.key })
    }
    
    /// Groups all transactions into date intervals based on the given period.
    /// - Parameter period: The time interval to group transactions into (e.g., 1 day, 1 week).
    /// - Returns: A list of 2-tuples that each contain the date interval and the list of transactions that occur within that interval.
    func groupAllByDateInterval(period: Period) -> [(key: DateInterval, value: [TransactionWrapper])] {
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
    
    /// Convert transactions from the Core Data interface class to a proxy class object that is more suited for the GUI.
    /// - Parameter transactions: The transactions from the Core Data store.
    /// - Parameter dateInterval: (optional) The date range to limit recurring transactions to. If not specified, recurring transactions will have proxy transactions created starting from their start date to the current date.
    /// - Parameter period: The time period to group generated recurring transactions.
    /// - Returns: The transactions as a set of one-off transactions and auto-generated recurring transactions.
    static func fromTransactions(_ transactions: [Transaction], in dateInterval: DateInterval? = nil, groupBy period: Period) -> TransactionSet {
        var oneOffTransactions: [TransactionWrapper] = []
        var recurringTransactions: [TransactionWrapper] = []
        
        for transaction in transactions {
            if transaction.recurrencePeriod == RecurrencePeriod.never.rawValue {
                oneOffTransactions.append(TransactionWrapper.fromTransaction(transaction))
            } else if let dateInterval = dateInterval {
                recurringTransactions.append(contentsOf: transaction.getRecurringTransactions(in: dateInterval, groupBy: period))
            } else {
                recurringTransactions.append(contentsOf: transaction.getRecurringTransactions(groupBy: period))
            }
        }
        
        return TransactionSet(oneOffTransactions: oneOffTransactions, recurringTransactions: recurringTransactions)
    }
}
