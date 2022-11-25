//
//  DateRepeatSheet.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

/// Form for selecting the data and the recurrence period of a transaction.
struct DateRepeatSheet: View {
    /// When the transaction occured.
    @Binding var date: Date
    /// How often the transaction repeats, if ever.
    @Binding var recurrencePeriod: RecurrencePeriod
    
    var body: some View {
        // TODO: Stop longer repeat period names from moving date column.
        Grid(alignment: .center) {
            GridRow {
                Label("Date", systemImage: "calendar")
                    .padding(.trailing)
                Label("Repeat", systemImage: "repeat")
            }
            
            GridRow {
                DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .padding(.trailing)
                RecurrencePeriodPicker(recurrencePeriod: $recurrencePeriod, allowNever: true)
            }
        }
        .padding(.top)
        .presentationDetents([.medium, .height(128)])
    }
}

struct DateRepeatSheet_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: Date.now) { $date in
            Stateful(initialState: RecurrencePeriod.weekly) { $recurrencePeriod in
                DateRepeatSheet(date: $date, recurrencePeriod: $recurrencePeriod)
            }
        }
    }
}
