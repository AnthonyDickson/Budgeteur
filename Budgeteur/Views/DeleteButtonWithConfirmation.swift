//
//  DeleteButtonWithConfirmation.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 27/11/22.
//

import SwiftUI

/// A button with red text that triggers a confirmation dialog.
struct DeleteButtonWithConfirmation<Label>: View where Label : View {
    /// The callback to call when the user taps on the delete button inside the confirmation dialog.
    var action: () -> ()
    /// The label of the button that triggers the confirmation dialog.
    @ViewBuilder var label: () -> Label
    
    /// Keeps track of whether the confirmation dialog should be shown.
    @State private var showDeleteDialog: Bool = false
    
    var body: some View {
        Button(role: .destructive) {
            showDeleteDialog = true
        } label: {
            label()
        }
        .confirmationDialog("Are you sure?", isPresented: $showDeleteDialog) {
            Button(role: .destructive, action: action) {
                Text("Delete")
            }
        } message: {
            Text("Deleted transactions cannot be recovered")
        }
    }
}

struct DeleteButtonWithConfirmation_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButtonWithConfirmation {
            print("delete tapped")
        } label: {
            Text("Delete")
        }
    }
}
