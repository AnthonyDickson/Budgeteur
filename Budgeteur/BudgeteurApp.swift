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
    @StateObject private var dataManager = DataManager.sample

    var body: some Scene {
        WindowGroup {
            ContentView(data: data)
                .environment(\.managedObjectContext, dataManager.context)
        }
    }
}
