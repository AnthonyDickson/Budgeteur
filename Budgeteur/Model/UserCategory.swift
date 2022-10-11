//
//  Category.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/10/22.
//

import Foundation

/// A user defined category for expenses.
struct UserCategory: Identifiable, Equatable {
    var id = UUID()
    var name: String
}
