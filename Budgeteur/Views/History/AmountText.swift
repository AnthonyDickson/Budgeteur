//
//  AmountText.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/11/22.
//

import SwiftUI

/// Display a currency amount, colored by whether it represents an expense or income.
struct AmountText: View {
    /// The amount of money transacted.
    var amount: Double
    /// Whether ``amount`` is an expense or income.
    var type: TransactionType
    
    var amountColor: Color {
        type == .expense ? expenseColor : incomeColor
    }
    
    var expenseColor: Color {
        colorScheme == .light ? .bloodOrange : .grapefruitRed
    }
    
    var incomeColor: Color {
        colorScheme == .light ? .moneyGreenDarker : .moneyGreen
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Text(Currency.format(amount))
            .foregroundColor(amountColor)
    }
}

struct AmountText_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AmountText(amount: 123.45, type: .expense)
            AmountText(amount: 543.21, type: .income)
        }
    }
}
