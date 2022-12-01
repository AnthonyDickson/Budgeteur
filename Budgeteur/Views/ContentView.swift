//
//  ContentView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        TabView {
            if sizeClass == .compact {
                Record()
                    .tabItem {
                        Label("Record", systemImage: "creditcard")
                    }
                
                History()
                    .tabItem {
                        Label("History", systemImage: "scroll")
                    }
            } else {
                HStack {
                    History()
                    Record()
                }
                .tabItem {
                    Label("Transactions", systemImage: "scroll")
                }
            }
            
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var dataManager = DataManager(inMemory: true)
        
        static var previews: some View {
            let previewDevices = [
                "iPhone 14 Pro",
                "iPad mini (6th generation)"
            ]
            
            ForEach(previewDevices, id: \.description) { previewDevice in
                ContentView()
                    .environment(\.managedObjectContext, dataManager.context)
                    .environmentObject(dataManager)
                    .onAppear {
                        dataManager.addSampleData(numSamples: 500)
                    }
                    .previewDisplayName(previewDevice)
                    .previewDevice(.init(rawValue: previewDevice))
            }
            
        }
    }
}
