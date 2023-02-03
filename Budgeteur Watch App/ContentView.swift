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
        [Keypad.backspaceSymbol, "0", Keypad.checkSymbol],
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
//        VStack {
//            ForEach(Keypad.rows, id: \.self) { row in
//                HStack {
//                    Spacer()
//
//                    ForEach(row, id: \.self) { value in
//                        switch(value) {
//                        case Keypad.backspaceSymbol:
//                            Button {
//                                removeLastDigit()
//                            } label: {
//                                Label("backspace", systemImage: "delete.backward")
//                                    .labelStyle(.iconOnly)
//                            }
//                            .disabled(invalidAmount)
//                            .foregroundColor(invalidAmount ? .gray : .red)
//
//                        case Keypad.checkSymbol:
//                            Button {
//                                onSave()
//                            } label: {
//                                Label("save", systemImage: "checkmark.circle")
//                                    .labelStyle(.iconOnly)
//                            }
//                            .disabled(invalidAmount)
//
//                        default:
//                            Button {
//                                addDigit(digit: value)
//                            } label: {
//                                Text(value)
//                            }
//                            .foregroundColor(.primary)
//                        }
//
//                        Spacer()
//                    }
//                    .bold()
//                    .padding()
//                }
//            }
//        }
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
                    .bold()
                    .padding(.vertical, 1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}


struct TransactionModal: View {
    @State var amount: Double = 0.0
    @State var name: String = ""
    @State var category: UserCategory? = nil

    var body: some View {
        Form {
            Section("Amount") {
//                TextField("Amount", text: $name, prompt: Text("Amount"))
                Text(Currency.format(amount))
                Keypad(amount: $amount)
            }
        }
    }
}

struct ContentView: View {
    var period: Period = .oneWeek
    
    @State private var showEditor = false
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
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
            .foregroundColor(isOverBudget ? .red : .primary)
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
            TransactionModal()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showEditor = false
                        }
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
    }
}
