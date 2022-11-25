//
//  RepeatPeriodPicker.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

/// Allows the user to choose a recurrence period.
struct RecurrencePeriodPicker: View {
    /// How often the transaction repeats, if ever.
    @Binding var recurrencePeriod: RecurrencePeriod
    /// Whether to show the user the recurrence period 'never'.
    ///
    /// This should be set to `false` for recurring transactions.
    /// The user should not be able to select 'never' for a recurring transaction, they should instead set an end date or delete the recurring transaction.
    var allowNever: Bool
    
    var body: some View {
        Picker(selection: $recurrencePeriod) {
            ForEach(RecurrencePeriod.allCases, id: \.rawValue) { period in
                if allowNever || period != .never {
                    Text(period.rawValue)
                        .tag(period)
                }
            }
        } label: {
            Text("Recurrence Period")
        }
        .pickerStyle(.automatic)
        .labelsHidden()
    }
}

struct RecurrencePeriodPicker_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: RecurrencePeriod.never) { $recurrencePeriod in
            RecurrencePeriodPicker(recurrencePeriod: $recurrencePeriod, allowNever: true)
        }
    }
}
