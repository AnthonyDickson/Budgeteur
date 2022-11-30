//
//  RecurringTransactionSubGroup.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 30/11/22.
//

import SwiftUI

/// Displays a divider followed by the text 'Recurring Transactions' that can be tapped to reveal recurring transactions.
///
/// Designed to be embeded within a `List`.
struct RecurringTransactionSubGroup: View {
    /// A list of recurring transactions.
    var recurringTransactions: [TransactionWrapper]
    
    /// Keeps track of whether the transactions a visible.
    @State private var showRecurringTransactions = false
    
    /// The angle of the chevron beside the text, indicating wether the transactions are collapsed (hidden) or expanded (visible).
    private var rotationAngle: Angle {
        showRecurringTransactions ? Angle(degrees: 90) : Angle(degrees: 0)
    }
    
    var body: some View {
        // A `VStack` is used here so that gap between the `Divider` and the `HStack` is small.
        VStack {
            Divider()
            
            HStack {
                Spacer()
                Text("Recurring Transactions")
                Label("Expand Grouped Transactions", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .rotationEffect(rotationAngle)
                .animation(.easeInOut.speed(2), value: showRecurringTransactions)
                Spacer()
            }
            .listRowSeparator(.hidden)
            .onTapGesture {
                withAnimation {
                    showRecurringTransactions.toggle()
                }
            }
        }
        .font(.footnote)
        .foregroundColor(Color(uiColor: .secondaryLabel))
       
        if showRecurringTransactions {
            // TODO: Sort by amount, descending
            TransactionRows(transactions: recurringTransactions, useDateForHeader: false)
        }
    }
}

struct RecurringTransactionSubGroup_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m = DataManager.init(inMemory: true)
        m.addSampleData(numSamples: 250)
        return m
    }()
    
    static var previews: some View {
        let period: Period = .oneWeek
        let transactions = try! dataManager.context.fetch(Transaction.fetchRequest())
        let (_, transactionSet) = TransactionSet.fromTransactions(transactions, groupBy: period)
            .groupByDateInterval(period: period)[0]
        
        List {
            RecurringTransactionSubGroup(recurringTransactions: transactionSet.recurringTransactions)
        }
    }
}
