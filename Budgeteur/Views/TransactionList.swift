//
//  TransactionList.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct TransactionList: View {
    var transactions: [Transaction]
    
    var body: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionList(transactions: DataModel().transactions)
    }
}
