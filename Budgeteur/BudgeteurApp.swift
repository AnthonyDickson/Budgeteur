//
//  BudgeteurApp.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

// TODO: Add README with screenshots.
// TODO: Add ability to set how much of an income transaction is saved and contributes to the budget.

import SwiftUI
/// An app for tracking your expenses and income, and assisting with your budgeting efforts!
@main
struct BudgeteurApp: App {
    @StateObject private var dataManager: DataManager = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(dataManager)
        }
    }
}
