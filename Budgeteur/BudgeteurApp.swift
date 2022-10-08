//
//  BudgeteurApp.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

@main
struct BudgeteurApp: App {
    @StateObject var dataModel = DataModel()

    var body: some Scene {
        WindowGroup {
            ContentView(dataModel: .constant(DataModel()))
        }
    }
}
