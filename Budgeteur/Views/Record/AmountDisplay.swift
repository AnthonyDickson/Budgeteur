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
}

/// Displays a currency amount with a money coloured backbround.
struct AmountDisplay: View {
    /// The currency amount.
    var amount: Double
    
    /// Whether the user's device has light or dark mode enabled.
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    /// The background color of the transaction amount. Reacts to whether dark mode is enabled.
    private var amountBackground: Color {
        colorScheme == .light ? Color.moneyGreen : Color.moneyGreenDarker
    }
    
    var body: some View {
        // TODO: Handle case where text overflows. Make text smaller?
        Text(Currency.format(amount))
            .font(.title)
            .bold()
            .frame(maxWidth: 180, maxHeight: 110)
            .padding()
            .background(amountBackground)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 4)
    }
}

struct AmountDisplay_Previews: PreviewProvider {
    static var previews: some View {
        AmountDisplay(amount: 123.45)
    }
}
