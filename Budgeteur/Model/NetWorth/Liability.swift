//
//  Liability.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/04/23.
//

import Foundation


typealias Liability = Asset

/// A collection of liabilities where each asset consists of a description and a cash value.
struct Liabilities {
    /// Debts and expenses that are due within a year such as credit card debt.
    let shortTermLiabilities: [Liability]
    /// Debts and expenses that are due to be paid in more than a year such as home loans.
    let longTermLiabilities: [Liability]
    
    static let shortTermDescription = "Short-term liabilities are debts and expenses that are due within a year such as credit card debt."
    static let longTermDescrription = "Long-term liabilities are debts and expenses that are due to be paid in more than a year such as home loans."
    
    /// The total value of all short-term liabilities.
    var shortTermTotal: Double {
        shortTermLiabilities.sum(\.value)
    }
    
    /// The total value of all long-term liabilities.
    var longTermTotal: Double {
        longTermLiabilities.sum(\.value)
    }
    
    /// The total value of all liabilities.
    var total: Double {
        shortTermTotal + longTermTotal
    }
    
    static var preview: Liabilities {
        Liabilities(
            shortTermLiabilities: [Liability(description: "Credit Card Debt", value: 897.32)],
            longTermLiabilities: [
                Liability(description: "Car Loan", value: 23689.12),
                Liability(description: "Phone Repayments", value: 1398.57)
            ]
        )
    }
}
