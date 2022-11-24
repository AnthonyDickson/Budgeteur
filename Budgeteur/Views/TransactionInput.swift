//
//  TransactionInput.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 24/11/22.
//

import SwiftUI
import CoreData

struct BudgetOverview: View {
    @EnvironmentObject private var dataManager: DataManager
    
    /// The user selected time period for aggregating transactions.
    @AppStorage("period") private var period: Period = .oneWeek
    

    func sumRecurringTransactions(for transaction: Transaction, in dateInterval: DateInterval) -> Double {
        // TODO: Refactor common parts of this func with func from `TransactionList`.
        let startDate =  Calendar.current.startOfDay(for: dateInterval.start)
        let today = Calendar.current.startOfDay(for: Date.now)
        
        guard let endOfToday = Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: today) else {
            fatalError("Error: Could create date by adding \(DateComponents(day: 1, second: -1)) to \(Date.now)")
        }
        
        let endDate: Date
        
        if let transactionEndDate = transaction.endDate, transactionEndDate < endOfToday {
            endDate = transactionEndDate
        } else {
            endDate = endOfToday
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
        let dailyAmount = transaction.amount * multiplier
        
        let isoCalendar = Calendar(identifier: .iso8601)
        let dateIncrement = period.getDateIncrement()

        var date = startDate
        
        var sum = 0.0
        
        // TODO: Change calculation to use num times in period * base price when period <= recurrence period. When recurrence period > period, fall back to fractional calculation.
        while date < endDate {
            guard let nextDate = isoCalendar.date(byAdding: dateIncrement, to: date) else {
                fatalError("Error: Could not increment date \(date) by increment \(dateIncrement)")
            }
            
            // The date intervals are closed intervals, but the .day component returns the length of the open interval so we need to add one to the result.
            let numDays = Calendar.current.dateComponents([.day], from: date, to: nextDate).day! + 1
            let amountForPeriod = dailyAmount * Double(numDays)
            
            sum += amountForPeriod
            
            date = nextDate
        }
        
        return sum
    }
    
    /// Get the total amount of all transactions in the current time period (e.g. this week, this month).
    private var totalSpending: Double {
        let dateInterval = period.getDateInterval(for: Date.now)
        
        let requestForOneOffTransactions = Transaction.fetchRequest()
        requestForOneOffTransactions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%@ <= date AND date <= %@", dateInterval.start as NSDate, dateInterval.end as NSDate),
            NSPredicate(format: "recurrencePeriod == %@", RecurrencePeriod.never.rawValue)
        ])
        
        let requestForRecurringTransactions = Transaction.fetchRequest()
        requestForRecurringTransactions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "recurrencePeriod != %@", RecurrencePeriod.never.rawValue),
            NSPredicate(format: "date <= %@", dateInterval.end as NSDate),
            NSPredicate(format: "endDate = nil OR endDate <= %@", dateInterval.end as NSDate)
        ])
        
        
        do {
            let oneOffTransactions = try dataManager.context.fetch(requestForOneOffTransactions)
            let recurringTransactions = try dataManager.context.fetch(requestForRecurringTransactions)
            
            let sum = oneOffTransactions.reduce(0.0) { partialResult, transaction in
                partialResult + transaction.amount
            } + recurringTransactions.reduce(0.0, { partialResult, transaction in
                partialResult + sumRecurringTransactions(for: transaction, in: dateInterval)
            })
            
            return sum
        } catch {
            fatalError("Error fetching transactions: \(error.localizedDescription)")
        }
    }
    
    /// Convert a time period to a context-aware label.
    private var timePeriodLabel: String {
        switch(period) {
        case .oneDay:
            return "today"
        case .oneWeek:
            return "this week"
        case .twoWeeks:
            return "this fortnight"
        case .oneMonth:
            return "this month"
        case .threeMonths:
            return "this quarter"
        case .oneYear:
            return "this year"
        }
    }
    
    /// A label with the total amount spent and the aggregation period.
    private var spendingSummary: String {
        "Spent \(Currency.format(totalSpending)) \(timePeriodLabel)"
    }
    
    var body: some View {
        Text(spendingSummary)
    }
}

/// A form for creating a new transaction. Features a big keypad.
struct TransactionInput: View {
    @EnvironmentObject private var dataManager: DataManager
    
    /// The amount of money spent.
    @State var amount = 0.0
    /// A description of the transaction.
    @State var label = ""
    /// When the transaction occured.
    @State var date = Date.now
    /// The ID of the category the transaction fits into (e.g., groceries vs. entertainment).
    @State var category: UserCategory? = nil
    /// How often the transaction repeats, if ever.
    @State var recurrencePeriod = RecurrencePeriod.never
    
    /// Whether to show the date/repitition controls.
    @State private var showDateControls = false
    
    /// Is the current amount invalid?
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    /// Add the transaction to the app's data.
    private func save() {
        _ = dataManager.createTransaction(amount: amount, label: label, date: date, recurrencePeriod: recurrencePeriod, category: category)
        reset()
    }
    
    /// Reset the inputs to their default values.
    private func reset() {
        withAnimation {
            label = ""
            amount = 0.0
            date = Date.now
            category = nil
            recurrencePeriod = .never
        }
    }
    
    var body: some View {
        // Need GeometryReader here to prevent the keyboard from moving the views (keyboard avoidance).
        GeometryReader { _ in
            VStack(alignment: .center) {
                ZStack {
                    BudgetOverview()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showDateControls = true
                        } label: {
                            Label("Change date and repetition.", systemImage: "ellipsis")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showDateControls) {
                            DateRepeatSheet(date: $date, recurrencePeriod: $recurrencePeriod)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                AmountDisplay(amount: amount)
                
                Spacer()
                
                TextField("What did you pay for?", text: $label)
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .padding()
                
                CategoryPicker(selectedCategory: $category)
                
                Keypad(amount: $amount, onSave: save)
            }
        }
        // Tapping on anything other than the description textfield will dismiss the keyboard.
        .onTapGesture {
            dismissKeyboard()
        }
        // This stops the keyboard from pushing up the keypad view
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct TransactionInput_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        TransactionInput()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
            .environmentObject(dataManager)
            .onAppear {
                dataManager.addSampleData()
            }
    }
}
