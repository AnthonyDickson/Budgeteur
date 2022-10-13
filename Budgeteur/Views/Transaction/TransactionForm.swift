//
//  TransactionForm.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import SwiftUI

extension Color {
    static let moneyGreen = Color(red: 0.49, green: 0.96, blue: 0.49)
    static let moneyGreenDarker = Color(red: 0.38, green: 0.72, blue: 0.38)
}

/// A form for creating a new transaction. Features a big keypad.
struct TransactionForm: View {
    /// The app data.
    @ObservedObject var data: DataModel
    
    /// A description of the transaction.
    @State var description = ""
    /// The amount of money spent.
    @State var amount = 0.0
    /// When the transaction occured.
    @State var date = Date.now
    /// The category the transaction fits into (e.g., groceries vs. entertainment).
    @State var category: UserCategory? = nil
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    /// Is the current amount invalid?
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    /// The background color of the transaction amount. Reacts to whether dark mode is enabled.
    private var amountBackground: Color {
        colorScheme == .light ? Color.moneyGreen : Color.moneyGreenDarker
    }
    
    /// Add the transaction to the app's data.
    private func save() {
        let transaction = Transaction(amount: amount, description: description, date: date, category: category)
        data.addTransaction(transaction)
        reset()
    }
    
    /// Reset the inputs to their default values.
    private func reset() {
        description = ""
        amount = 0.0
        date = Date.now
        category = nil
        focusedField = nil
    }
    
    /// Enumerates the selectable fields in the view.
    private enum Field: Hashable {
        case description
        case date
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .center) {
            // TODO: Add summary of how much has been spent for the selected time period (data.period).
            Text(Currency.format(amount))
                .font(.title)
                .bold()
                .padding(25)
                .padding(.horizontal)
                .background(amountBackground)
                .cornerRadius(10)
            
            TextField("What did you pay for?", text: $description)
                // Focused helps ensure the keyboard will be dismissed if the save button is pressed.
                .focused($focusedField, equals: .description)
                .submitLabel(.done)
                .multilineTextAlignment(.center)
                .padding()
            
            DatePicker("Date", selection: $date, displayedComponents: [.date])
                .focused($focusedField, equals: .date)
                .labelsHidden()
                .padding(.bottom)
        
            CategorySelector(categories: $data.categories, selectedCategory: $category)
            
            Spacer()
            
            Keypad(amount: $amount, onSave: save)
        }
        .navigationTitle("Add Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear", role: .cancel) {
                    reset()
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(invalidAmount)
            }
        }
        // Tapping on anything other than the description textfield will dismiss the keyboard.
        .onTapGesture {
            focusedField = nil
        }
        // This stops the keyboard from pushing up the keypad view
        .ignoresSafeArea(.keyboard)
    }
}

struct TransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        TransactionForm(data: DataModel())
    }
}
