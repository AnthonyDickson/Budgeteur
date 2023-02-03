//
//  BudgeteurWatchApp.swift
//  Budgeteur Watch App
//
//  Created by Anthony Dickson on 31/01/23.
//

import SwiftUI

// TODO: Transfer data from iOS app to WatchOS app https://developer.apple.com/documentation/watchos-apps/keeping-your-watchos-app-s-content-up-to-date
// TODO: View that shows budget summary similar to that of the iOS widget.
// TODO: View for creating new transaction. May be best to display as a sequence of views. Should include the basics: amount, income/expense, tag and description.

@main
struct Budgeteur_Watch_App: App {
    @StateObject private var dataManager: DataManager = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(dataManager)
        }
    }
}
