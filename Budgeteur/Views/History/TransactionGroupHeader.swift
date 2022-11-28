//
//  TransactionGroupHeader.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 28/11/22.
//

import SwiftUI

/// Displays the title of a group of transactions (e.g., date or category name) and the total income and expenses for the group.
struct TransactionGroupHeader: View {
    /// The title of the group.
    var title: String
    /// The total income for the group.
    var totalIncome: Double
    /// The total expenses for the group.
    var totalExpenses: Double

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(uiColor: .label))
            Spacer()
            // Need to specify alignment otherwise the decimal points may not line up if one value is much larger than the other.
            VStack(alignment: .trailing) {
                Text(Currency.format(totalIncome))
                Text(Currency.format(-totalExpenses))
            }
            .monospacedDigit()
        }
    }
}

struct TransactionGroupHeader_Previews: PreviewProvider {
    static var previews: some View {
        TransactionGroupHeader(title: "Income", totalIncome: 100000.11, totalExpenses: 500)
    }
}
