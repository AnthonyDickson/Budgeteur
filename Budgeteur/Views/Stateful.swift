//
//  Utils.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 10/10/22.
//

import SwiftUI


/// A wrapper view that provides a mutable Binding to its content closure.
///
/// Useful in Xcode Previews for interactive previews of views that take a Binding.
/// Credit: User Ole on github [gist.github.com/ole/4c43c92fe425d662186afd04dd800b4f](https://gist.github.com/ole/4c43c92fe425d662186afd04dd800b4f)
struct Stateful<Value, Content: View>: View {
    var content: (Binding<Value>) -> Content
    @State private var state: Value
    
    init(initialState: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._state = State(initialValue: initialState)
        self.content = content
    }
    
    var body: some View {
        content($state)
    }
}
