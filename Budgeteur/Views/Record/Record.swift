//
//  TransactionForm.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import SwiftUI


/// A form for creating a new transaction. Features a big keypad.
struct Record: View {
    /// The app data.
    @ObservedObject var data: DataModel
    
    /// A description of the transaction.
    @State var description = ""
    /// The amount of money spent.
    @State var amount = 0.0
    /// When the transaction occured.
    @State var date = Date.now
    /// The ID of the category the transaction fits into (e.g., groceries vs. entertainment).
    @State var categoryID: UUID? = nil
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
        let transaction = Transaction(
            amount: amount,
            description: description,
            categoryID: categoryID,
            date: date,
            recurrencePeriod: recurrencePeriod
        )
        data.addTransaction(transaction)
        reset()
    }
    
    /// Reset the inputs to their default values.
    private func reset() {
        withAnimation {
            description = ""
            amount = 0.0
            date = Date.now
            categoryID = nil
            recurrencePeriod = .never
        }
    }
    
    var body: some View {
        // Need GeometryReader here to prevent the keyboard from moving the views (keyboard avoidance).
        GeometryReader { _ in
            VStack(alignment: .center) {
                ZStack {
                    BudgetOverview(period: data.period, transactions: data.transactions)
                    
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
                
                TextField("What did you pay for?", text: $description)
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .padding()
                
                CategorySelector(categories: $data.categories, selectedCategory: $categoryID)
                
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
    static var previews: some View {
        Record(data: DataModel())
    }
}
