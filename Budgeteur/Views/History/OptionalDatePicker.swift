//
//  OptionalDatePicker.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/11/22.
//

import SwiftUI

/// Allows the user to pick a date or no date (nil).
///
/// Intended to be used within a `Form` for the `endDate` attribute of ``TransactionItem``.
struct OptionalDatePicker: View {
    /// The optional date.
    @Binding var date: Date?
    /// A partial range giving the earliest selectable date.
    var dateRange: PartialRangeFrom<Date>
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                ZStack(alignment: .leading) {
                    DatePicker(
                        "End Date",
                        selection: Binding<Date>(
                            get: { date ?? Date.now },
                            set: { date = $0 }
                        ),
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    
                    if date == nil {
                        // This HStack and the Spacer are needed to push the text to left-hand side.
                        HStack {
                            Text("None")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        // The frame and background are used to hide the date picker.
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        // This allows the user to tap through to the date picker.
                        .allowsHitTesting(false)
                    }
                }
                
                Spacer()
                
                if date != nil {
                    Button(role: .destructive) {
                        date = nil
                    } label: {
                        Label("Delete", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    // This is needed to ensure the tap area of the button is more accurate. Without this the button spans the entire empty area.
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct OptionalDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        let startingDate: Date? = .now
        let dateRange = Calendar.current.date(byAdding: DateComponents(day: -7), to: startingDate!)!...
        
        Stateful(initialState: startingDate) { $date in
            Form {
                OptionalDatePicker(
                    date: $date,
                    dateRange: dateRange
                )
            }
        }
    }
}
