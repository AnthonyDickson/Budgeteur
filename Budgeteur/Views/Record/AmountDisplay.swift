//
//  AmountDisplay.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

/// Displays a currency amount with a money coloured backbround.
struct AmountDisplay: View {
    /// How much money was spent/earned.
    var amount: Double
    /// What percent of the amount is put aside as savings. **Note:** Only applicable to income transactions.
    var savings: Double
    /// Whether money was spent or earned.
    var transactionType: TransactionType
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    /// The background color of the transaction amount. Reacts to whether dark mode is enabled.
    private var amountBackground: Color {
        switch transactionType {
        case .expense:
            return expenseBackground
        case .income:
            return incomeBackground
        }
    }
    
    private var incomeBackground: Color {
        colorScheme == .light ? .moneyGreen : .moneyGreenDarker
    }
    
    private var expenseBackground: Color {
        colorScheme == .light ? .grapefruitRed : .bloodOrange
    }
    
    private var titleText: String {
        switch transactionType {
        case .expense:
            return "Spent"
        case .income:
            return "Earned"
        }
    }
    
    private var scaleXAmount: Double {
        transactionType == .expense ? 1.0 : -1.0
    }
    
    private var rotationAmount: Angle {
        .degrees(transactionType == .expense ? 0 : -180)
    }
    
    private var spendingMoney: Double {
        (1.0 - savings) * amount
    }
    
    private var savingsPercent: String {
        savings.formatted(.percent.precision(.fractionLength(0)))
    }
    
    var body: some View {
        // TODO: Handle case where text overflows. Make text smaller?
        VStack {
            Text(titleText)
            
            Text(Currency.format(amount))
                .font(.largeTitle)
                .bold()
            
            if transactionType == .income {
                Text(Currency.format(spendingMoney) + " after " + savingsPercent + " saved")
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: 256)
        .background(amountBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 4)
        .scaleEffect(x: scaleXAmount, y: 1.0)
        .rotation3DEffect(rotationAmount, axis: (x: 0, y: 1, z: 0))
    }
}

struct AmountDisplay_Previews: PreviewProvider {
    static var previews: some View {
        AmountDisplay(amount: 123.45, savings: 0.0, transactionType: .expense)
            .previewDisplayName("Expense View")
        
        AmountDisplay(amount: 123.45, savings: 0.1, transactionType: .income)
            .previewDisplayName("Income View")
    }
}
