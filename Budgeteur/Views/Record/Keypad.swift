//
//  AmountKeypad.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import SwiftUI

extension Color {
    /// The system color for disabled buttons
    static var disabled: Color { Color(UIColor.systemGray3) }
}

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
                            .foregroundColor(invalidAmount ? .disabled : .red)
                            
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
                                dismissKeyboard()
                            } label: {
                                Text(value)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .font(.title)
                    .bold()
                    .padding()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}


struct Keypad_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Stateful(initialState: 0) { $amount in
                VStack {
                    Text(Currency.format(amount))
                    Keypad(amount: $amount)
                }
            }
            .previewDisplayName("Keypad Zero")
            
            Stateful(initialState: 123) { $amount in
                VStack {
                    Text(Currency.format(amount))
                    Keypad(amount: $amount)
                }
            }
            .previewDisplayName("Keypad Non-Zero")
        }
    }
}
