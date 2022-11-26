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
    @StateObject private var dataManager: DataManager = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(dataManager)
        }
    }
}
