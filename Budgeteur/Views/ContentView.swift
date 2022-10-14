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
        TabView(selection: $selectedTab) {
            NavigationStack {
                Record(data: data)
            }
            .tabItem {
                Label("Record", systemImage: "creditcard")
            }
            .tag(Tab.new)
            
            NavigationStack {
                History(data: data)
            }
            .tabItem {
                Label("History", systemImage: "list.bullet")
            }
            .tag(Tab.list)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(data: DataModel())
    }
}
