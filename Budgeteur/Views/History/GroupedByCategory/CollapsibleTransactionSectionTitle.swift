//
//  CollapsibleTransactionSectionTitle.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 28/11/22.
//

import SwiftUI

/// Displays a string title and optionally displays the percentage of income/expenses the section makes up of the total income/expenses for the current reporting period.
/// 
struct CollapsibleTransactionSectionTitle: View {
    /// The name of the section.
    var title: String
    /// The net income (income - expenses) for the section.
    var netIncome: Double
    /// The total income for the current reporting period.
    var totalIncome: Double?
    /// The total expenses for the current reporting period.
    var totalExpenses: Double?
    
    /// Displays the percent of the total income/expenses the section accounts for in the current reporting period along with text specifying whether the given figure is for income or expenses, if ``totalIncome`` or ``totalExpenses`` are specified.
    private var percentOfTotalLabel: String? {
        if let totalIncome = totalIncome, netIncome > 0 {
            return abs(netIncome / totalIncome).formatted(.percent.precision(.fractionLength(0))) + " of total income"
        } else if let totalExpenses = totalExpenses, netIncome < 0 {
            return abs(netIncome / totalExpenses).formatted(.percent.precision(.fractionLength(0))) + " of total expenses"
        }
        
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            if let percentOfTotalLabel = percentOfTotalLabel {
                Text(percentOfTotalLabel)
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        }
    }
}

struct CollapsibleTransactionSectionTitle_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CollapsibleTransactionSectionTitle(title: "Income", netIncome: 123, totalIncome: 1234)
            CollapsibleTransactionSectionTitle(title: "Expense", netIncome: -123, totalExpenses: 4321)
            CollapsibleTransactionSectionTitle(title: "Income w/o Percentage", netIncome: -123)
            CollapsibleTransactionSectionTitle(title: "Expense w/o Percentage", netIncome: -123)
        }
    }
}
