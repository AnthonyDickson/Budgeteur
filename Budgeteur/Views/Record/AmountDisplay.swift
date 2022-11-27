//
//  AmountDisplay.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

extension Color {
    static let moneyGreen = Color(red: 0.49, green: 0.96, blue: 0.49)
    static let moneyGreenDarker = Color(red: 0.38, green: 0.72, blue: 0.38)
    
    static let grapefruitRed = Color(red: 1, green: 0.6, blue: 0.6)
    static let bloodOrange = Color(red: 0.76, green: 0.39, blue: 0.39)
}

/// Displays a currency amount with a money coloured backbround.
struct AmountDisplay: View {
    /// The currency amount.
    var amount: Double
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
    
    var body: some View {
        // TODO: Handle case where text overflows. Make text smaller?
        VStack {
            Text(titleText)
            Text(Currency.format(amount))
                .font(.title)
                .bold()
        }
        .padding()
        .frame(maxWidth: 180, maxHeight: 110)
        .background(amountBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 4)
        .scaleEffect(x: scaleXAmount, y: 1.0)
        .rotation3DEffect(rotationAmount, axis: (x: 0, y: 1, z: 0))
    }
}

struct AmountDisplay_Previews: PreviewProvider {
    static var previews: some View {
        AmountDisplay(amount: 123.45, transactionType: .expense)
            .previewDisplayName("Expense View")
        
        AmountDisplay(amount: 123.45, transactionType: .income)
            .previewDisplayName("Income View")
    }
}
