//
//  ContentView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct ContentView: View {
    /// The container for the app's data.
    @ObservedObject var data: DataModel
    
    var body: some View {
        TabView {
            NavigationStack {
                TransactionInput()
            }
            .tabItem {
                Label("New", systemImage: "creditcard")
            }
            
            TransactionList()
                .tabItem {
                    Label("History", systemImage: "scroll")
                }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var dataManager = DataManager(inMemory: true)
        
        static var previews: some View {
            ContentView(data: DataModel())
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(dataManager)
                .onAppear {
                    dataManager.addSampleData()
                }
        }
    }
}
