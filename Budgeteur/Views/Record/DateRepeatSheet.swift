//
//  DateRepeatSheet.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

struct DateRepeatSheet: View {
    @Binding var date: Date
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
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                    .padding(.trailing)
                RecurrencePeriodPickerOld(recurrencePeriod: $recurrencePeriod)
            }
        }
        .padding(.top)
        .presentationDetents([.medium, .height(128)])
    }
}

struct DateRepeatSheet_Previews: PreviewProvider {
    static var previews: some View {
        DateRepeatSheet(date: .constant(Date.now), recurrencePeriod: .constant(.never))
    }
}
