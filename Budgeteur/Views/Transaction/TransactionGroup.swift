//
//  TransactionGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

/// Shows transctions grouped by a category in a collapsable view.
struct TransactionGroup: View {
    /// The name of the category that the transactions belong to.
    var categoryName: String
    /// The transaction data.
    var transactions: [Transaction]
    /// What to do when a user taps on a transaction row.
    var onRowTap: (_ transaction: Transaction) -> ()
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
                    TransactionRow(transaction: transaction)
                        .padding(.leading)
                        .onTapGesture {
                            onRowTap(transaction)
                        }
                }
                .onDelete { indexSet in
                    onRowDelete(indexSet)
                }
            }
        } header: {
            HStack {
                Text("Spent \(totalAmount) on \(categoryName)")
                Spacer()
                Text("\(transactions.count) item\(transactions.count > 1 ? "s" : "")")
                Label("Expand Grouped Transactions", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .rotationEffect(showTransactions ? Angle(degrees: 90) : Angle(degrees: 0))
                    .animation(.easeInOut.speed(2), value: showTransactions)
            }
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .foregroundColor(.primary)
            .onTapGesture {
                withAnimation {
                    showTransactions.toggle()
                }
            }
        }
    }
}

struct TransactionGroup_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        TransactionGroup(
            categoryName: data.categories[0].name,
            transactions: data.transactions.filter({ $0.categoryID == data.categories[0].id }),
            onRowTap: {_ in},
            onRowDelete: {_ in}
        )
    }
}
