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
    /// - Parameter period: The time period to report by (e.g. weekly)
    /// - Returns: The list of generated transactions.
    func getRecurringTransactions(in dateInterval: DateInterval? = nil, groupBy period: Period) -> [TransactionWrapper] {
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
        
        let recurringTransactionInterval: DateInterval
        
        if let dateInterval = dateInterval {
            // We want the shortest interval, so we:
            // 1) get the latest date of `startDate` and the `dateInterval.start`;
            let lastestStartDate = startDate > dateInterval.start ? startDate : dateInterval.start
            // and 2) get the earliest of `endDate` and `dateInterval.end`
            let earliestEndDate = endDate < dateInterval.end ? endDate : dateInterval.end
            recurringTransactionInterval = DateInterval(start: lastestStartDate, end: earliestEndDate)
        } else {
            recurringTransactionInterval = DateInterval(start: startDate, end: endDate)
        }
        
        guard let recurrencePeriod = RecurrencePeriod(rawValue: self.recurrencePeriod) else {
            fatalError("Error: Could not convert '\(self.recurrencePeriod)' to a valid enum value of RecurrencePeriod.")
        }
        
        guard recurrencePeriod != .never else {
            return []
        }
        
        let useWholeAmounts = recurrencePeriod.days <= period.days
        
        if useWholeAmounts {
            return getRecurringTransactionsWholeAmounts(in: recurringTransactionInterval, every: recurrencePeriod, using: isoCalendar)
        } else {
            return getRecurringTransactionsFractionalAmounts(in: recurringTransactionInterval, every: recurrencePeriod, reportingBy: period, using: isoCalendar)
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
            transactions.append(TransactionWrapper(
                amount: self.amount,
                savings: self.savings,
                type: TransactionType(rawValue: self.type)!,
                label: self.label,
                date: date,
                recurrencePeriod: recurrencePeriod,
                category: self.category,
                parent: self
            ))
            
            date = calendar.date(byAdding: dateIncrement, to: date)!
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
        // TODO: Calculate year length, num weeks and num fortnights based on `date`. Make sure to account for leap years.
        let yearLength = 365.25
        let dailyAmount: Double
        
        switch recurrencePeriod {
        case .never:
            fatalError("Given non-recurring transaction (recurrencePeriod == .never) when a recurring transaction was expected.")
        case .daily:
            dailyAmount = self.amount
        case .weekly:
            dailyAmount = self.amount * 52.1785 / yearLength
        case .fortnightly:
            dailyAmount = self.amount * 26.0892 / yearLength
        case .monthly:
            dailyAmount = self.amount * 12 / yearLength
        case .quarterly:
            dailyAmount = self.amount * 3 / yearLength
        case .yearly:
            dailyAmount = self.amount * 1 / yearLength
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
                savings: self.savings,
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
    
    /// Get the predicate to get either one-off or recurring transactions, optionally within a date interval.
    /// - Parameters:
    ///   - recurring: Whether to get recurring transactions (true) or one-off transactions (false).
    ///   - dateInterval: If specified, only fetch the transactions that occur within this range of dates.
    /// - Returns: A predicate that can be used to query the Core Data store for transactions.
    static func getPredicate(recurring: Bool, in dateInterval: DateInterval?) -> NSPredicate {
        var predicates: [NSPredicate] = []
        
        if recurring {
            predicates.append(NSPredicate(format: "recurrencePeriod != %@", RecurrencePeriod.never.rawValue))
            
            if let dateInterval = dateInterval {
                predicates.append(
                    NSPredicate(format: "date <= %@ AND (endDate == nil OR endDate >= %@)", dateInterval.end as NSDate, dateInterval.start as NSDate))
            }
        } else {
            predicates.append(NSPredicate(format: "recurrencePeriod == %@", RecurrencePeriod.never.rawValue))
            
            if let dateInterval = dateInterval {
                predicates.append(
                    NSPredicate(format: "date BETWEEN {%@, %@}", dateInterval.start as NSDate, dateInterval.end as NSDate))
            }
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    /// Get the predicate to get all transactions, optionally within a given date interval.
    /// - Parameter dateInterval: If specified, only fetch the transactions that occur within this range of dates.
    /// - Returns: A predicate that can be used to query the Core Data store for transactions.
    static func getPredicateForAllTransactions(in dateInterval: DateInterval? = nil) -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            Self.getPredicate(recurring: false, in: dateInterval),
            Self.getPredicate(recurring: true, in: dateInterval)
        ])
    }
}
