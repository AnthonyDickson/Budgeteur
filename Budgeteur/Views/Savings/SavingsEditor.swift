//
//  SavingsEditor.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 28/12/22.
//

import SwiftUI

struct SavingsEditor: View {
    /// How much money was spent/earned.
    var amount: Double
    /// What percent of the amount is put aside as savings.
    @Binding var savings: Double
    
    static private let percentFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Spending Money")
                        .font(.headline)
                    Text(Currency.format((1 - savings) * amount))
                }
                
                Spacer()
                
                VStack {
                    Text("Savings")
                        .font(.headline)
                    Text(Currency.format(savings * amount))
                }
            }
            
            VStack {
                Slider(value: $savings, in: 0...1, step: 0.01)
                Text("Saving " + (Self.percentFormatter.string(for: savings) ?? "NaN"))
            }
        }
    }
}

struct SavingsEditor_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: 0.3) { $savings in
            SavingsEditor(amount: 420, savings: $savings)
        }
    }
}
