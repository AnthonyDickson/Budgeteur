//
//  Record.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 24/11/22.
//

import SwiftUI
import CoreData

/// A form for creating a new transaction. Features a big keypad.
struct Record: View {
    @EnvironmentObject private var dataManager: DataManager
    
    /// The amount of money spent.
    @State private var amount = 0.0
    /// A description of the transaction.
    @State private var label = ""
    /// When the transaction occured.
    @State private var date = Date.now
    /// The ID of the category the transaction fits into (e.g., groceries vs. entertainment).
    @State private var category: UserCategory? = nil
    /// How often the transaction repeats, if ever.
    @State private var recurrencePeriod = RecurrencePeriod.never
    /// Whether money was spent or earned.
    @State private var transactionType: TransactionType = .expense
    
    /// Is the current amount invalid?
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    /// Prompts the user to type in what they paid for or earned money from.
    private var memoPlaceholder: String {
        if transactionType == .expense {
            return "What did you pay for?"
        } else {
            return "What did you earn money from?"
        }
    }
    
    /// Add the transaction to the app's data.
    private func save() {
        _ = dataManager.createTransaction(amount: amount, type: transactionType, label: label, date: date, recurrencePeriod: recurrencePeriod, category: category)
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
    
    /// Toggle between adding expenses and income.
    private func toggleTransactionType() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if transactionType == .expense {
                transactionType = .income
            } else {
                transactionType = .expense
            }
        }
    }
    
    var body: some View {
        // Need GeometryReader here to prevent the keyboard from moving the views (keyboard avoidance).
        GeometryReader { _ in
            VStack(alignment: .center) {
                RecordTitleBar(date: $date, recurrencePeriod: $recurrencePeriod)
                
                Spacer()

                AmountDisplay(amount: amount, transactionType: transactionType)
                    .onTapGesture(perform: toggleTransactionType)
                
                Spacer()
                
                TextField(memoPlaceholder, text: $label)
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

struct Record_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        Record()
            .environment(\.managedObjectContext, dataManager.container.viewContext)
            .environmentObject(dataManager)
            .onAppear {
                dataManager.addSampleData()
            }
    }
}
