//
//  ReccuringTransactionGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 16/10/22.
//

import SwiftUI

/// Shows transctions grouped by a category in a collapsable view.
struct ReccuringTransactionGroup: View {
    /// The transaction data.
    var transactions: [RecurringTransaction]
    /// A function that gets the name of the category that a transaction belong to.
    var getCategoryName: (_ categoryID: UUID?) -> String
    /// What to do when a user taps on a transaction row.
    var onRowTap: (_ transaction: RecurringTransaction) -> ()
    /// What to do when a user deletes a transaction.
    var onRowDelete: (_ indexSet: IndexSet) -> ()
    
    /// Whether to display the individual transactions.
    @State private var showTransactions  = false
    
    /// A formatted string containing the sum of the transaction amounts.
    private var totalAmount: String {
        let total = transactions.reduce(0) { $0 + $1.amount}
        
        return Currency.format(total)
    }
    
    var body: some View {
        Section {
            // TODO: Animate the group being expanded with a sliding animation.
            if showTransactions {
                ForEach(transactions) { transaction in
                    RecurringTransactionRow(transaction: transaction, getCategoryName: getCategoryName)
                        .padding(.leading)
                        .onTapGesture {
                            onRowTap(transaction)
                        }
                }
                .onDelete { indexSet in
                    // TODO: Convert the index set from index of the recurring transactions to index of the parent transactions.
                    onRowDelete(indexSet)
                }
            }
        } header: {
            HStack {
                Text("\(totalAmount) on Recurring")
                Spacer()
                Text("\(transactions.count) item\(transactions.count > 1 ? "s" : "")")
                Label("Expand Grouped Transactions", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .rotationEffect(showTransactions ? Angle(degrees: 90) : Angle(degrees: 0))
                    .animation(.easeInOut.speed(2), value: showTransactions)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .onTapGesture {
                withAnimation {
                    showTransactions.toggle()
                }
            }
        }
    }
}

struct ReccuringTransactionGroup_Previews: PreviewProvider {
    static var data = DataModel()

    static var previews: some View {
        List {
            ReccuringTransactionGroup(
                transactions: data.transactions
                    .filter { $0.categoryID == data.categories[0].id }
                    .map { RecurringTransaction(amount: $0.amount, description: $0.description, categoryID: $0.categoryID, date: $0.date, recurrencePeriod: $0.recurrencePeriod, parentID: $0.id) },
                getCategoryName: data.getCategoryName,
                onRowTap: {_ in},
                onRowDelete: {_ in}
            )
        }
        .listStyle(.inset)
    }
}
