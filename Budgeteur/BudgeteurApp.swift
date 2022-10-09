//
//  BudgeteurApp.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

@main
struct BudgeteurApp: App {
    @StateObject private var data = DataModel()

    var body: some Scene {
        WindowGroup {
            ContentView(data: data)
        }
    }
}
