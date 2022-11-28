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
    /// The total income for the current reporting period.
    ///
    /// Specify this if you want the section header to include text describing the percentage of the total income that the section accounts for.
    var totalIncome: Double?
    /// The total expenses for the current reporting period.
    ///
    /// Specify this if you want the section header to include text describing the percentage of the total expense that the section accounts for.
    var totalExpenses: Double?
    
    /// Whether to expand the transactions list. Defaults to having the list collapsed (false).
    ///
    /// Set this to `true` if you want the view to start with the section expanded.
    @State var showTransactions = false
    
    private var netIncome: Double {
        transactions.reduce(0.0) { $1.type == .expense ? $0 - $1.amount : $0 + $1.amount }
    }
    
    private var transactionType: TransactionType {
        netIncome >= 0 ? .income : .expense
    }
    
    var body: some View {
        Section {
            if showTransactions {
                TransactionRows(transactions: transactions, useDateForHeader: useDateForHeader)
                    .padding(.leading, 20)
            }
        } header: {
            HStack {
                CollapsibleTransactionSectionTitle(title: title, netIncome: netIncome, totalIncome: totalIncome, totalExpenses: totalExpenses)
                Spacer()
                AmountText(amount: abs(netIncome), type: transactionType)
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
        
        let (_, transactionsForGroupingByCategory) = transactionSet.groupAllByDateInterval(period: period)[0]
        let (category, categoryTransactions) = TransactionGroupCategory.groupByCategory(transactionsForGroupingByCategory)[0]
        
        
        List {
            Section {
                CollapsibleTransactionSection(title: title, transactions: groupedTransactions, useDateForHeader: false)
            }
        }
        .previewDisplayName("Grouped by Date")
        
        List {
            Section {
                CollapsibleTransactionSection(title: category?.name ?? UserCategory.defaultName, transactions: categoryTransactions, useDateForHeader: true, totalIncome: 1000, totalExpenses: 1000)
            }
        }
        .previewDisplayName("Grouped by Category")
    }
}
