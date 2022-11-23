//
//  RepeatPeriodPicker.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

struct RecurrencePeriodPickerOld: View {
    @Binding var recurrencePeriod: RecurrencePeriod
    
    var body: some View {
        Button {
            recurrencePeriod = recurrencePeriod.getNext()
        } label: {
            Text(recurrencePeriod.rawValue)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
        }
        .buttonStyle(.borderless)
    }
}

struct RecurrencePeriodPicker_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: RecurrencePeriod.never) { $recurrencePeriod in
            RecurrencePeriodPickerOld(recurrencePeriod: $recurrencePeriod)
        }
    }
}
