//
//  Settings.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 26/11/22.
//

import SwiftUI

/// Displays various app settings, including buttons to manage sample data.
struct Settings: View {
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var sampleCount = 500.0
    @State private var addRecurring = true
    
    var body: some View {
        Form {
            Section("Sample Data") {
                Text("Samples: \(Int(sampleCount))")
                Slider(value: $sampleCount, in: 100...50000, step: 100) {
                    Text("Sample Count")
                }
                
                Toggle("Add Recurring Transactions", isOn: $addRecurring)
                
                Button {
                    dataManager.addSampleData(numSamples: Int(sampleCount), addRecurring: addRecurring)
                    dataManager.save()
                } label: {
                    Text("Add sample data")
                }
                
                DeleteButtonWithConfirmation {
                    dataManager.deleteAll()
                    dataManager.save()
                } label: {
                    Text("Delete all data")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var dataManager: DataManager = .init(inMemory: true)
    
    static var previews: some View {
        Settings()
            .environmentObject(dataManager)
    }
}
