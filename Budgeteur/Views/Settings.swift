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
    
    var body: some View {
        Form {
            Section("Sample Data") {
                Button {
                    dataManager.addSampleData()
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
