//
//  Transaction.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import Foundation

extension Transaction {
    /// Get the total of the recurring transactions within a given date interval.
    /// - Parameter period: The reporting period (e.g. weekly) to group transactions into.
    /// - Returns: The sum of the recurring transactions.
    func sumRecurringTransactions(in dateInterval: DateInterval, groupBy period: Period) -> Double {
        return getRecurringTransactions(groupBy: period)
            .filter({ dateInterval.start <= $0.date && $0.date <= dateInterval.end })
            .sum(\.amount)
    }
    
    /// Generate proxy transaction objects for a given base transaction.
    /// - Parameter period: The reporting period (e.g. weekly) to group transactions into.
    /// - Returns: The list of generated transactions.
    func getRecurringTransactions(groupBy period: Period) -> [TransactionItem] {
        var recurringTransactions: [TransactionItem] = []
        
        let startDate =  Calendar.current.startOfDay(for: self.date)
        let today = Calendar.current.startOfDay(for: Date.now)
        
        guard let endOfToday = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: today) else {
            fatalError("Error: Could create date by adding \(DateComponents(day: 1, second: -1)) to \(Date.now)")
        }
        
        let endDate: Date
        
        if let transactionEndDate = self.endDate, transactionEndDate < endOfToday {
            endDate = transactionEndDate
        } else {
            endDate = endOfToday
        }
        
        guard let recurrencePeriod = RecurrencePeriod(rawValue: self.recurrencePeriod) else {
            fatalError("Error: Could not convert '\(self.recurrencePeriod)' to a valid enum value of RecurrencePeriod.")
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
        
        let dailyAmount = self.amount * multiplier
        
        let isoCalendar = Calendar(identifier: .iso8601)
        let dateIncrement = period.getDateIncrement()
        var date = startDate
        
        // TODO: Change calculation to use num times in period * base price when period <= recurrence period. When recurrence period > period, fall back to fractional calculation.
        while date < endDate {
            guard let nextDate = isoCalendar.date(byAdding: dateIncrement, to: date) else {
                fatalError("Error: Could not increment date \(date) by increment \(dateIncrement)")
            }
            
            // The date intervals are closed intervals, but the .day component returns the length of the open interval so we need to add one to the result.
            let numDays = Calendar.current.dateComponents([.day], from: date, to: nextDate).day! + 1
            let amountForPeriod = dailyAmount * Double(numDays)
            
            recurringTransactions.append(TransactionItem(
                id: UUID(),
                amount: amountForPeriod,
                label: self.label,
                date: date,
                recurrencePeriod: recurrencePeriod,
                category: self.category,
                parent: self
            ))
            
            date = nextDate
        }
        
        return recurringTransactions
    }
}
