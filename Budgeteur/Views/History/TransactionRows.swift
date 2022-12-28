//
//  TransactionRows.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI
import CoreData

/// How to sort transactions in ``TransactionRows``.
enum RowSortOrder {
    /// Sort transactions by amount in descending order.
    case amount
    /// Sort transactions by date in descending order.
    case date
}

/// Creates a ForEach displaying each transaction as a ``TransactionRow``.
struct TransactionRows: View {
    /// The collection of transactions to display in this section.
    var transactions: [TransactionWrapper]
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool
    /// How to sort the transactions.
    var sortBy: RowSortOrder = .date
    
    private var sortedTransactions: [TransactionWrapper] {
        switch sortBy {
        case .amount:
            return transactions.sorted(by: { $0.amount > $1.amount })
        case .date:
            return transactions.sorted(by: { $0.date > $1.date })
        }
    }
    
    @State private var selectedTransaction: TransactionWrapper? = nil
    
    var body: some View {
        ForEach(sortedTransactions) { transaction in
            TransactionRow(transaction: transaction, useDateForHeader: useDateForHeader)
                .onTapGesture {
                    selectedTransaction = transaction
                }
        }
        .sheet(item: $selectedTransaction) { transaction in
            NavigationStack {
                TransactionEditor(transaction: transaction)
            }
        }

    }
}

struct TransactionRows_Previews: PreviewProvider {    
    static var fetchRequest: NSFetchRequest<Transaction> {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 10
        return request
    }
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! DataManager.preview.context.fetch(fetchRequest)
        let transactionSet = TransactionSet.fromTransactions(transactions, groupBy: period)
        
        List {
            TransactionRows(transactions: transactionSet.oneOffTransactions, useDateForHeader: false)
        }
    }
}
