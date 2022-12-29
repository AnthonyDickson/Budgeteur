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
            Slider(value: $savings, in: 0...1, step: 0.01)
            
            HStack {
                VStack {
                    Text("Spending")
                        .font(.headline)
                    Text(Currency.format((1 - savings) * amount))
                }
                .frame(minWidth: 80)
                
                Spacer()
                
                VStack {
                    Text("Save")
                        .font(.headline)
                    Text(Self.percentFormatter.string(for: savings) ?? "NaN")
                }
                .frame(minWidth: 80)
                
                Spacer()
                
                VStack {
                    Text("Savings")
                        .font(.headline)
                    Text(Currency.format(savings * amount))
                }
                .frame(minWidth: 80)
            }
        }
        .monospacedDigit()
    }
}

struct SavingsEditor_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: 0.3) { $savings in
            SavingsEditor(amount: 1234, savings: $savings)
                .padding()
        }
    }
}
