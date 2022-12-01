//
//  SearchBar.swift
//  Budgeteur
//
//  Created by Anthony Dickson on 1/12/22.
//

import SwiftUI

/// A textfield that looks like a native search bar.
struct SearchBar: View {
    /// The text the user is searching for.
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Label("Search transactions", systemImage: "magnifyingglass")
                .labelStyle(.iconOnly)
                .foregroundColor(Color(uiColor: .tertiaryLabel))
            
            TextField("Search", text: $searchText)
                .submitLabel(.search)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Label("Clear search", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
                // The plain button style disables the distracting press animation that covers the entire row.
                .buttonStyle(.plain)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SearchBar(searchText: .constant(""))
            SearchBar(searchText: .constant("Hello, world!"))
        }
    }
}
