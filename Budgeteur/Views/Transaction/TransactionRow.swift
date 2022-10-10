//
//  TransactionRow.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

/// The details of a single transaction intended to be view inside of a List view.
struct TransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Currency.format(transaction.amount))
                Text(transaction.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.shortDate)
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction.sample)
    }
}
