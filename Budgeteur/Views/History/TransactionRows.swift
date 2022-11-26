//
//  TransactionRows.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI
import CoreData

/// Creates a ForEach displaying each transaction as a ``TransactionRow``.
struct TransactionRows: View {
    /// The collection of transactions to display in this section.
    var transactions: [TransactionItem]
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool
    
    @State private var selectedTransaction: TransactionItem? = nil
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        // TODO: Enable sorting by either date or amount.
        ForEach(transactions.sorted(by: { $0.date > $1.date })) { transaction in
            TransactionRow(transaction: transaction, useDateForHeader: useDateForHeader)
                .onTapGesture {
                    selectedTransaction = transaction
                }
        }
        .onDelete { indexSet in
            DispatchQueue.main.async {
                for index in indexSet {
                    context.delete(transactions[index].parent)
                }
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
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        m.addSampleData()
        return m
    }()
    
    static var fetchRequest: NSFetchRequest<Transaction> {
        let request = Transaction.fetchRequest()
        request.fetchLimit = 10
        return request
    }
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! dataManager.context.fetch(fetchRequest)
        let transactionSet = TransactionSet.fromTransactions(transactions, groupBy: period)
        
        List {
            TransactionRows(transactions: transactionSet.oneOffTransactions, useDateForHeader: false)
        }
    }
}
