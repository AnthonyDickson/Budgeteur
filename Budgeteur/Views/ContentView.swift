//
//  ContentView.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 9/10/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var dataModel: DataModel
    
    var body: some View {
        TransactionList(transactions: dataModel.transactions)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataModel: .constant(DataModel()))
    }
}
