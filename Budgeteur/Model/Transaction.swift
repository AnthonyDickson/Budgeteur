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
        return getRecurringTransactions(in: dateInterval, groupBy: period)
            .filter { dateInterval.contains($0.date) }
            .sum(\.amount)
    }
    
    /// Generate proxy transaction objects for a given base transaction.
    /// - Parameter dateInterval: The date interval to filter the transactions by.
    /// - Parameter period: The reporting period (e.g. weekly) to group transactions into.
    /// - Returns: The list of generated transactions with the given date interval.
    func getRecurringTransactions(in dateInterval: DateInterval, groupBy period: Period) -> [TransactionWrapper] {
        return getRecurringTransactions(groupBy: period)
            .filter { dateInterval.contains($0.date) }
    }
    
    /// Generate proxy transaction objects for a given base transaction.
    /// - Parameter period: The time period to report by (e.g. weekly)
    /// - Returns: The list of generated transactions.
    func getRecurringTransactions(groupBy period: Period) -> [TransactionWrapper] {
        let isoCalendar = Calendar(identifier: .iso8601)
        let startDate = isoCalendar.startOfDay(for: self.date)
        let today = isoCalendar.startOfDay(for: Date.now)
        let endOfToday = isoCalendar.date(byAdding: DateComponents(day: 1, second: -1), to: today)!
        
        let endDate: Date
        
        if let transactionEndDate = self.endDate, transactionEndDate < endOfToday {
            endDate = transactionEndDate
        } else {
            endDate = endOfToday
        }
        
        let dateInterval = DateInterval(start: startDate, end: endDate)
        
        guard let recurrencePeriod = RecurrencePeriod(rawValue: self.recurrencePeriod) else {
            fatalError("Error: Could not convert '\(self.recurrencePeriod)' to a valid enum value of RecurrencePeriod.")
        }
        
        guard recurrencePeriod != .never else {
            return []
        }
        
        let useWholeAmounts = recurrencePeriod.days <= period.days
        
        if useWholeAmounts {
            return getRecurringTransactionsWholeAmounts(in: dateInterval, every: recurrencePeriod, using: isoCalendar)
        } else {
            return getRecurringTransactionsFractionalAmounts(in: dateInterval, every: recurrencePeriod, reportingBy: period, using: isoCalendar)
        }
    }
    
    /// Helper function for generating the proxy transaction objects for a recurring transaction using whole amounts.
    /// - Parameters:
    ///   - dateInterval: The start and end dates for which transactions should be generated.
    ///   - recurrencePeriod: How often the transaction repeats.
    ///   - calendar: The calendar to use when doing date arithmetic.
    /// - Returns: A list of proxy transaction objects.
    private func getRecurringTransactionsWholeAmounts(in dateInterval: DateInterval, every recurrencePeriod: RecurrencePeriod, using calendar: Calendar) -> [TransactionWrapper] {
        let dateIncrement = recurrencePeriod.getDateIncrement()
        
        var transactions: [TransactionWrapper] = []
        var date = dateInterval.start
        
        while date < dateInterval.end {
            let nextDate = calendar.date(byAdding: dateIncrement, to: date)!
            
            transactions.append(TransactionWrapper(
                amount: self.amount,
                type: TransactionType(rawValue: self.type)!,
                label: self.label,
                date: date,
                recurrencePeriod: recurrencePeriod,
                category: self.category,
                parent: self
            ))
            
            date = nextDate
        }
        
        return transactions
    }
    
    
    /// Helper function for generating the proxy transaction objects for a recurring transaction using fractional amounts.
    ///
    /// For example if a transaction repeats every month but the user has selected a reporting period of one week, a transaction is created every week using the average amount (base amount / number of day in month \* number of days in week).
    /// This gives the user an idea of the average amount per reporting period (e.g., how much does Netflix cost me each week?).
    /// - Parameters:
    ///   - dateInterval: The start and end dates for which transactions should be generated.
    ///   - recurrencePeriod: How often the transaction repeats.
    ///   - period: The reporting period (e.g. weekly) to group transactions into.
    ///   - calendar: The calendar to use when doing date arithmetic.
    /// - Returns: A list of proxy transaction objects.
    private func getRecurringTransactionsFractionalAmounts(in dateInterval: DateInterval, every recurrencePeriod: RecurrencePeriod, reportingBy period: Period, using calendar: Calendar) -> [TransactionWrapper] {
        var recurringTransactions: [TransactionWrapper] = []
        // TODO: Calculate year length, num weeks and num fortnights based on `date`.
        let yearLength = 365.25
        let dailyAmount: Double
        
        switch recurrencePeriod {
        case RecurrencePeriod.daily:
            dailyAmount = self.amount
        case RecurrencePeriod.weekly:
            dailyAmount = self.amount * 52.1785 / yearLength
        case RecurrencePeriod.fortnightly:
            dailyAmount = self.amount * 26.0892 / yearLength
        case RecurrencePeriod.monthly:
            dailyAmount = self.amount * 12 / yearLength
        case RecurrencePeriod.quarterly:
            dailyAmount = self.amount * 3 / yearLength
        case RecurrencePeriod.yearly:
            dailyAmount = self.amount * 1 / yearLength
        default:
            fatalError("Given non-recurring transaction (recurrencePeriod == .never) when a recurring transaction was expected.")
        }
        
        let dateIncrement = period.getDateIncrement()
        
        var date = dateInterval.start
        while date < dateInterval.end {
            let nextDate = calendar.date(byAdding: dateIncrement, to: date)!
            
            // The date intervals are closed intervals, but the .day component returns the length of the open interval so we need to add one to the result.
            let numDays = calendar.dateComponents([.day], from: date, to: nextDate).day!
            let amountForPeriod = dailyAmount * Double(numDays)
            
            recurringTransactions.append(TransactionWrapper(
                amount: amountForPeriod,
                type: TransactionType(rawValue: self.type)!,
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
