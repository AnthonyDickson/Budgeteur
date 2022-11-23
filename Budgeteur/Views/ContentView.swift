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
    /// The tab that is currently displayed.
    @State private var selectedTab: Tab = .new
    
    enum Tab {
        case new
        case list
    }
    
    var body: some View {
        NavigationStack {
            TransactionList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataManager = DataManager(inMemory: true)
    
    static var previews: some View {
        
        return ContentView(data: DataModel())
            .environment(\.managedObjectContext, dataManager.context)
            .environmentObject(dataManager)
            .onAppear {
                dataManager.addSampleData()
            }
    }
}
