//
//  PeriodPicker.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 12/10/22.
//

import SwiftUI

/// Picks a time period for aggregating transactions.
struct PeriodPicker: View {
    /// The chosen time period.
    @Binding var selectedPeriod: Period
    
    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(Period.allCases) { period in
                Text(period.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct PeriodPicker_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: Period.oneWeek) { $period in
            VStack {
                Text(period.rawValue)
                PeriodPicker(selectedPeriod: $period)
            }
        }
    }
}
