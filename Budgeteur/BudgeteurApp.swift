//
//  BudgeteurApp.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI
/// An app for tracking your expenses and income, and assisting with your budgeting efforts!
@main
struct BudgeteurApp: App {
    @StateObject private var data = DataModel()

    var body: some Scene {
        WindowGroup {
            ContentView(data: data)
        }
    }
}
