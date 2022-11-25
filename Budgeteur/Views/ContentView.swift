//
//  ContentView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Record()
            }
            .tabItem {
                Label("New", systemImage: "creditcard")
            }
            
            History()
                .tabItem {
                    Label("History", systemImage: "scroll")
                }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var dataManager = DataManager(inMemory: true)
        
        static var previews: some View {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(dataManager)
                .onAppear {
                    dataManager.addSampleData()
                }
        }
    }
}
