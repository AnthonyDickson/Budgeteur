//
//  DissmissKeyboard.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 14/10/22.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
