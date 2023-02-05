//
//  ContentView.swift
//  Budgeteur Watch App
//
//  Created by Anthony Dickson on 31/01/23.
//

import SwiftUI

/// Displays an interactive 10 digit keypad with delete and submit buttons.
struct Keypad: View {
    @Binding var amount: Double
    /// Callback for when the user taps the checkmark button.
    var onSave: () -> () = {}
    
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    static private let backspaceSymbol = "<"
    static private let checkSymbol = "ok"
    
    static private let rows = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        [Keypad.backspaceSymbol, "0"],
    ]
    
    /// Removes the last digit of the amount and shifts the decimal point left one place, e.g. 123.45 -> 12.34.
    private func removeLastDigit() {
        amount = floor(amount * 10) / 100
    }
    
    /// Add a digit to the amount and shift the decimal point right, e.g.:
    /// ```
    /// keypad.amount = 123.45
    /// keypad.addDigit("6")
    /// print(keypad.amount)
    /// 1234.56
    /// ```
    /// - Parameter digitString: A string of a single digit, e.g. "1".
    private func addDigit(digit digitString: String) {
        guard digitString.count == 1 else {
            return
        }
        
        guard let digit = Double(digitString) else {
            return
        }
        
        amount = amount * 10 + Double(digit) / 100
    }
    
    var body: some View {
        Grid {
            ForEach(Keypad.rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { value in
                        switch(value) {
                        case Keypad.backspaceSymbol:
                            Button {
                                removeLastDigit()
                            } label: {
                                Label("backspace", systemImage: "delete.backward")
                                    .labelStyle(.iconOnly)
                            }
                            .disabled(invalidAmount)
                            .foregroundColor(invalidAmount ? .gray : .red)

                        case Keypad.checkSymbol:
                            Button {
                                onSave()
                            } label: {
                                Label("save", systemImage: "checkmark.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .disabled(invalidAmount)

                        default:
                            Button {
                                addDigit(digit: value)
                            } label: {
                                Text(value)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 2.5)
                }
                // This makes the view fill the width of the container.
                .frame(maxWidth: .infinity)
            }
        }
        .bold()
        // This button style (.plain or .borderless) is needed otherwise tapping one button activates all buttons at once.
        .buttonStyle(.plain)
    }
}

/// Holds the three attributes of a transaction that the user can set in the watch app.
struct DraftTransaction {
    var amount: Double = 0.0
    var label: String = ""
    var userCategory: UserCategory? = nil
}

/// The sheet view for adding a new expense.
struct ExpenseModal: View {
    @Binding var draftTransaction: DraftTransaction
    
    @Environment(\.managedObjectContext) private var context

    private var categories: [UserCategory] {
        // Using a `@FetchRequest` data member crashes the preview, but this works fine for some reason...
        let request = UserCategory.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", TransactionType.expense.rawValue)
        
        return try! context.fetch(request)
    }

    var body: some View {
        let categories = Array(categories)
        
        Form {
            Section("Amount") {
                Text(Currency.format(draftTransaction.amount))
                Keypad(amount: $draftTransaction.amount)
            }
            
            Section("Description") {
                TextField("description", text: $draftTransaction.label, prompt: Text("Description"))
            }
            
            Section("Category") {
                Picker("Category", selection: $draftTransaction.userCategory) {
                    // To support an optional selection type and an empty selection (`nil`), we need to add an option here that is selected
                    Text(UserCategory.defaultName)
                        .tag(nil as UserCategory?)
                    
                    ForEach(categories, id: \.id) { theCategory in
                        Text(theCategory.name)
                            // Must cast to optional to match the type of `selection`, otherwise tapping on items in the picker does nothing.
                            .tag(theCategory as UserCategory?)
                    }
                }
                .labelsHidden()
            }
        }
    }
}

struct ContentView: View {
    var period: Period = .oneWeek
    
    @State private var showEditor = false
    @State private var draftTransaction = DraftTransaction()
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var dataManager: DataManager
    
    private var transactions: TransactionSet {
        let dateInterval = period.getDateInterval(for: .now)

        let request = Transaction.fetchRequest()
        request.predicate = Transaction.getPredicateForAllTransactions(in: dateInterval)
        
        let transactions = try! context.fetch(request)
        
        return TransactionSet.fromTransactions(transactions, in: dateInterval, groupBy: period)
    }
    
    private var budgetOverview: some View {
        let transactionSet = self.transactions
        let netSpending = transactionSet.netSpending
        let isOverBudget = netSpending < 0
        
        let amount = Currency.formatAsInt(abs(netSpending))
        let underOver = isOverBudget ? "over" : "under"
        
        return Text("\(amount) \(underOver) budget \(period.contextLabel)")
            .padding()
    }
    
    private func addExpense() {
        _ = Transaction(
            insertInto: context,
            amount: draftTransaction.amount,
            type: .expense,
            label: draftTransaction.label,
            userCategory: draftTransaction.userCategory
        )
        
        dataManager.save()
        // TODO: Add haptic feedback when successfully adding a transaction? https://developer.apple.com/design/human-interface-guidelines/patterns/playing-haptics/

        draftTransaction = DraftTransaction()
    }

    var body: some View {
        VStack {
            budgetOverview
            
            Spacer()

            Button("Add Expense") {
                showEditor = true
            }
            .foregroundColor(.blue)
        }
        .padding()
        .sheet(isPresented: $showEditor) {
            ExpenseModal(draftTransaction: $draftTransaction)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showEditor = false
                            // TODO: Fix view not updating after a transaction is added. Probably need to use a  `@FetchRequest` variable similar to `TransactionGroup`, but it crashes the preview (this works in the simulator).
                            addExpense()
                        }
                        .foregroundColor(.blue)
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataManager.preview.context)
            .environmentObject(DataManager.preview)
            .previewDisplayName("Overview")

        Stateful(initialState: DraftTransaction()) { $transaction in
            ExpenseModal(draftTransaction: $transaction)
                .environment(\.managedObjectContext, DataManager.preview.context)
                .environmentObject(DataManager.preview)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                        }
                    }
                }
                .previewDisplayName("Add Transaction View")
        }
    }
}
