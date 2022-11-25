//
//  RecordTitleBar.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 25/11/22.
//

import SwiftUI

/// Displays the expenses for the selected period and a button that reveals extra controls.
struct RecordTitleBar: View {
    /// When the transaction occured.
    @Binding var date: Date
    /// How often the transaction repeats, if ever.
    @Binding var recurrencePeriod: RecurrencePeriod
    
    /// Whether to show the date/repitition controls.
    @State private var showControls: Bool = false
    
    var body: some View {
        ZStack {
            BudgetOverview()
            
            HStack {
                Spacer()
                
                Button {
                    showControls = true
                } label: {
                    Label("Change date and repetition.", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showControls) {
                DateRepeatSheet(date: $date, recurrencePeriod: $recurrencePeriod)
            }
        }
    }
}

struct RecordTitleBar_Previews: PreviewProvider {
    static var dataManager: DataManager = {
        let m: DataManager = .init(inMemory: true)
        
        _ = m.createTransaction(amount: 405, date: Date.now)
        _ = m.createTransaction(amount: 15, date: Date.distantPast, recurrencePeriod: .weekly)
        
        return m
    }()
    
    static var previews: some View {
        Stateful(initialState: Date.now) { $date in
            Stateful(initialState: RecurrencePeriod.weekly) { $recurrencePeriod in
                RecordTitleBar(date: $date, recurrencePeriod: $recurrencePeriod)
                    .environment(\.managedObjectContext, dataManager.context)
            }
        }
    }
}
