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
    @ObservedObject var data: DataModel
    
    @State var description = ""
    @State var amount = 0.0
    @State var date = Date.now
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private var invalidAmount: Bool {
        amount <= 0
    }
    
    /// The background color of the transaction amount. Reacts to whether dark mode is enabled.
    private var amountBackground: Color {
        colorScheme == .light ? Color.moneyGreen : Color.moneyGreenDarker
    }
    
    /// Add the transaction to the app's data.
    private func save() {
        let transaction = Transaction(amount: amount, description: description, date: date)
        data.addTransaction(transaction)
        reset()
    }
    
    /// Reset the inputs to their default values.
    private func reset() {
        description = ""
        amount = 0.0
        date = Date.now
        focusedField = nil
    }
    
    /// Enumerates the selectable fields in the view.
    private enum Field: Hashable {
        case description
        case date
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: .zero) {
            Text(Currency.format(amount))
                .font(.title)
                .padding()
                .background(amountBackground)
                .cornerRadius(10)
                // Extra padding is needed so we have space between the background and top of the list below.
                .padding(.bottom, 10)
            
            List {
                Section("Description"){
                    TextField("What did you pay for?", text: $description)
                        // Focused helps ensure the keyboard will be dismissed if the save button is pressed.
                        .focused($focusedField, equals: .description)
                        .submitLabel(.done)
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                        .focused($focusedField, equals: .date)
                        .labelsHidden()
                }
            }
            .listStyle(.grouped)
            
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
