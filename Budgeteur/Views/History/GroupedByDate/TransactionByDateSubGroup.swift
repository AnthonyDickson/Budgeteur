//
//  TransactionByDateSubGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 30/11/22.
//

import SwiftUI


/// Displays a divider with the date followed by the transactions for that date.
///
/// Should be embeded within a `List`.
struct TransactionByDateSubGroup: View {
    /// The date to display and that the transactions ocurred on.
    var date: Date
    /// The one-off transactions to display.
    var transactions: [TransactionWrapper]
    
    var body: some View {
        ZStack {
            Divider()
            Text(DateFormat.format(date))
                .font(.subheadline)
                .padding(.horizontal)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        
        TransactionRows(transactions: transactions, useDateForHeader: false)
    }
}

struct TransactionByDateSubGroup_Previews: PreviewProvider {
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! DataManager.preview.context.fetch(Transaction.fetchRequest())
        let (_, transactionSet) = TransactionSet.fromTransactions(transactions, groupBy: period)
            .groupByDateInterval(period: period)[0]
        let (date, transactionsOfDate) = transactionSet.groupOneOffByDate()[0]
        
        List {
            TransactionByDateSubGroup(date: date, transactions: transactionsOfDate)
        }
    }
}
