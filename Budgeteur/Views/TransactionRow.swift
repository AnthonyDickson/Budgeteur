//
//  TransactionRow.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct TransactionRow: View {
    static let dateFormat = Date.FormatStyle.dateTime.day().month(.abbreviated)
    
    var transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.formattedAmount)
                Text(transaction.description)
            }
            Spacer()
            Text(transaction.date.formatted(TransactionRow.dateFormat))
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction.sample)
    }
}
