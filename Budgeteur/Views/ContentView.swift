//
//  ContentView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.scenePhase) private var scenePhase

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
        // TODO: Fix this not updating widget (at least in simulator).
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            let previewDevices = [
                "iPhone 14 Pro",
                "iPad mini (6th generation)"
            ]
            
            ForEach(previewDevices, id: \.description) { previewDevice in
                ContentView()
                    .environment(\.managedObjectContext, DataManager.preview.context)
                    .environmentObject(DataManager.preview)
                    .previewDisplayName(previewDevice)
                    .previewDevice(.init(rawValue: previewDevice))
            }
            
        }
    }
}
