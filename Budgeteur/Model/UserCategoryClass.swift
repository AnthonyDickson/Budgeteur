//
//  Category.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 11/10/22.
//

import Foundation

/// A user defined category for expenses.
struct UserCategoryClass: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    
    static let defaultName = "Untagged"
}
