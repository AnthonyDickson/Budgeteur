//
//  DataModel.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import Foundation

final class DataModel: ObservableObject {
    var transactions = Array(repeating: Transaction.sample, count: 10)
}
