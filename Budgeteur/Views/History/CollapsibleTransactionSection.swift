//
//  CollapsibleTransactionSection.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// A section that the user can collapse/expand by tapping on the header.
struct CollapsibleTransactionSection: View {
    /// The string to display in the section header
    var title: String
    /// The collection of transactions to display in this section.
    var transactions: [TransactionWrapper]
    /// Whether to use the date or the category for the header title.
    var useDateForHeader: Bool
    /// Whether to expand the transactions list. Defaults to having the list collapsed (false).
    @State var showTransactions = false
    
    var netIncome: Double {
        transactions.reduce(0.0) { partialResult, transaction in
            transaction.type == .expense ? partialResult - transaction.amount : partialResult + transaction.amount
        }
    }
    
    var body: some View {
        Section {
            if showTransactions {
                TransactionRows(transactions: transactions, useDateForHeader: useDateForHeader)
                    .padding(.leading, 20)
            }
        } header: {
            HStack {
                Text(title)
                Spacer()
                AmountText(amount: abs(netIncome), type: netIncome > 0 ? .income : .expense)
                    .bold(showTransactions)
                
                Label("Expand Grouped Transactions", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .rotationEffect(showTransactions ? Angle(degrees: 90) : Angle(degrees: 0))
                    .animation(.easeInOut.speed(2), value: showTransactions)
            }
            .onTapGesture {
                withAnimation {
                    // TODO: Animate rows with a slide in from the top animation.
                    showTransactions.toggle()
                }
            }
        }
    }
}

struct CollapsibleTransactionSection_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        m.addSampleData()
        return m
    }()
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
        let (_, transactionSet) = TransactionSet.fromTransactions(transactions, groupBy: period)
            .groupByDateInterval(period: period)[0]
        let (date, groupedTransactions) = transactionSet.groupOneOffByDate()[0]
        let title = DateFormat.format(date)
        
        
        List {
            Section {
                CollapsibleTransactionSection(title: title, transactions: groupedTransactions, useDateForHeader: false)
            }
        }
    }
}
