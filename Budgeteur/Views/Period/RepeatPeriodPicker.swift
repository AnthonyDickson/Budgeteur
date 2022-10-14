//
//  RepeatPeriodPicker.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

struct RepeatPeriodPicker: View {
    @Binding var repeatPeriod: RepeatPeriod
    
    var body: some View {
        Button {
            repeatPeriod = repeatPeriod.getNext()
        } label: {
            Text(repeatPeriod.rawValue)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
        }
        .buttonStyle(.borderless)
    }
}

struct RepeatPeriodPicker_Previews: PreviewProvider {
    static var previews: some View {
        Stateful(initialState: RepeatPeriod.never) { $repeatPeriod in
            RepeatPeriodPicker(repeatPeriod: $repeatPeriod)
        }
    }
}
